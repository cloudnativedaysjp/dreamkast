# frozen_string_literal: true

require 'json'
require 'time'
require 'logger'
require 'active_support/tagged_logging'

module Logging
  # 1行1JSONの構造化ログを出力するフォーマッタ。
  #
  # - ActiveSupport::TaggedLogging のタグはメッセージへ前置しない。
  #   Hash のタグ（`config.log_tags` に Hash を返す Proc を指定した場合）は名前付きフィールドとして展開し、
  #   ActiveJob が付ける "ActiveJob" のような文字列タグは `tags` 配列にまとめる
  # - OpenTelemetry のスパンが有効な場合は trace_id / span_id を付与する
  # - lograge の Raw フォーマッタが渡す Hash はトップレベルにマージする
  #
  # 起動時（config/environments/*.rb）に require して使うため、Zeitwerk の autoload 対象からは除外している。
  # config/application.rb の `autoload_lib(ignore:)` を参照。
  class JsonLogFormatter < ::Logger::Formatter
    include ActiveSupport::TaggedLogging::Formatter

    # JSON化できないメッセージを inspect した際の最大長
    MAX_INSPECT_LENGTH = 4096

    # バックトレースを保持する最大行数
    MAX_BACKTRACE_LINES = 30

    def call(severity, timestamp, progname, msg)
      payload = { time: format_timestamp(timestamp), level: severity.to_s }
      payload.merge!(tag_fields)
      payload.merge!(trace_fields)
      payload[:progname] = progname.to_s if progname
      payload.merge!(message_fields(msg))

      dump(payload)
    end

    private

    def format_timestamp(timestamp)
      (timestamp || Time.now).utc.iso8601(3)
    end

    # Hash のタグは名前付きフィールドに展開し、それ以外のタグは `tags` 配列にまとめる。
    def tag_fields
      tags = current_tags
      return {} if tags.empty?

      fields = {}
      others = []
      tags.each do |tag|
        if tag.is_a?(::Hash)
          fields.merge!(tag.transform_keys(&:to_sym))
        else
          others << tag.to_s
        end
      end
      fields[:tags] = others unless others.empty?
      fields
    end

    def trace_fields
      return {} unless defined?(::OpenTelemetry::Trace)

      context = ::OpenTelemetry::Trace.current_span.context
      return {} unless context.valid?

      { trace_id: context.hex_trace_id, span_id: context.hex_span_id }
    rescue StandardError
      {}
    end

    def message_fields(msg)
      case msg
      when ::Hash
        msg.transform_keys(&:to_sym)
      when ::Exception
        exception_fields(msg)
      when ::String
        { message: msg }
      else
        { message: truncate(msg.inspect) }
      end
    end

    def exception_fields(exception)
      {
        message: exception.message.to_s,
        error_class: exception.class.name,
        backtrace: exception.backtrace&.first(MAX_BACKTRACE_LINES)
      }
    end

    def truncate(string)
      string.length > MAX_INSPECT_LENGTH ? "#{string[0, MAX_INSPECT_LENGTH]}…" : string
    end

    def dump(payload)
      "#{::JSON.generate(payload)}\n"
    rescue StandardError => e
      dump_fallback(payload, e)
    end

    # 不正なエンコーディングやJSON化できない値が混ざっていても、ログ出力自体は失敗させない
    def dump_fallback(payload, error)
      scrubbed = payload.to_h { |key, value| [key, safe_value(value)] }
      scrubbed[:log_format_error] = "#{error.class}: #{error.message}"
      "#{::JSON.generate(scrubbed)}\n"
    rescue StandardError
      %({"level":"ERROR","message":"failed to format log entry"}\n)
    end

    def safe_value(value)
      case value
      when ::String then value.dup.force_encoding(Encoding::UTF_8).scrub
      when ::Numeric, ::TrueClass, ::FalseClass, ::NilClass then value
      when ::Array then value.map { |element| safe_value(element) }
      when ::Hash then value.to_h { |key, element| [safe_value(key.to_s), safe_value(element)] }
      else safe_value(truncate(value.inspect))
      end
    end
  end
end
