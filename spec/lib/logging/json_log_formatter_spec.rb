require 'rails_helper'
require_relative '../../../lib/logging/json_log_formatter'

describe Logging::JsonLogFormatter do
  let(:io) { StringIO.new }
  let(:logger) do
    ActiveSupport::Logger.new(io).tap { |logger|
      logger.formatter = described_class.new
      logger.extend(ActiveSupport::TaggedLogging)
    }
  end

  def logged_lines
    io.string.each_line.map { |line| JSON.parse(line) }
  end

  describe '基本のフィールド' do
    it '1行1JSONで time / level / message を出力すること' do
      logger.info('hello')

      expect(io.string.lines.size).to eq(1)
      expect(logged_lines.first).to include(
        'level' => 'INFO',
        'message' => 'hello'
      )
      expect(logged_lines.first['time']).to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\z/)
    end

    it 'ログレベルが反映されること' do
      logger.warn('careful')

      expect(logged_lines.first['level']).to eq('WARN')
    end
  end

  describe 'タグの扱い' do
    it 'Hash のタグをメッセージに前置せず、名前付きフィールドとして出力すること' do
      logger.tagged({ request_id: 'req-1' }) { logger.info('hello') }

      expect(logged_lines.first).to include(
        'request_id' => 'req-1',
        'message' => 'hello'
      )
    end

    it 'Hash 以外のタグ（ActiveJob など）は tags 配列にまとめること' do
      logger.tagged({ request_id: 'req-1' }, 'ActiveJob', 'SqsAdapter') { logger.info('hello') }

      expect(logged_lines.first).to include(
        'request_id' => 'req-1',
        'tags' => ['ActiveJob', 'SqsAdapter']
      )
    end

    it 'タグが無い場合はタグ関連のフィールドを出力しないこと' do
      logger.info('hello')

      expect(logged_lines.first.keys).not_to include('request_id', 'tags')
    end
  end

  describe 'メッセージの型ごとの扱い' do
    it 'Hash はトップレベルのフィールドとして展開すること（lograge の Raw フォーマッタ相当）' do
      logger.info({ method: 'GET', path: '/events/cndt2026', status: 200, duration: 35.2 })

      expect(logged_lines.first).to include(
        'method' => 'GET',
        'path' => '/events/cndt2026',
        'status' => 200,
        'duration' => 35.2
      )
      expect(logged_lines.first).not_to have_key('message')
    end

    it 'Exception は message / error_class / backtrace に展開すること' do
      begin
        raise ArgumentError, 'boom'
      rescue ArgumentError => e
        logger.error(e)
      end

      expect(logged_lines.first).to include(
        'message' => 'boom',
        'error_class' => 'ArgumentError'
      )
      expect(logged_lines.first['backtrace']).to be_an(Array)
    end

    it 'その他のオブジェクトは inspect した文字列を message にすること' do
      logger.info([1, 2])

      expect(logged_lines.first['message']).to eq('[1, 2]')
    end
  end

  describe '異常系' do
    it '不正なエンコーディングを含む場合でも例外を出さずJSONを出力すること' do
      logger.info(+"invalid\xffbyte".force_encoding(Encoding::UTF_8))

      line = logged_lines.first
      expect(line['message']).to include('invalid')
      expect(line['log_format_error']).to be_present
    end
  end
end
