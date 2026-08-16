# ログのJSONフォーマット化チェックリスト

## 概要
production環境のログを1行1JSONの構造化ログに変更する。
リクエストログは `lograge` で1リクエスト=1イベントに集約し、それ以外のログ（`Rails.logger.info` など）も
独自フォーマッタでJSON化する。OpenTelemetry導入済みのため `trace_id` / `span_id` も各ログ行に付与し、
トレースとログを突き合わせられるようにする。

## 方針
- 対象環境: **production のみ**（development / test は従来の可読フォーマットのまま）
- gem: `lograge` を追加
- `request_id` は `config.log_tags` のタグ文字列ではなく、JSONのフィールドとして出力する
  - `config.log_tags` に Hash を返す Proc を指定し、フォーマッタ側で名前付きフィールドに展開する
  - ActiveJob などが積む文字列タグは `tags` 配列にまとめる（`request_id` を汚さない）
- ログ本文にPIIが混入しないよう、リクエストパラメータは出力しない

## 出力フォーマット（例）

リクエストログ（lograge）:
```json
{"time":"2026-08-16T07:06:26.578Z","level":"INFO","request_id":"req-abc123","method":"GET","path":"/events/cndt2026","format":"html","controller":"EventsController","action":"show","status":200,"allocations":31,"duration":0.03,"view":12.0,"db":8.1}
```

その他のログ:
```json
{"time":"2026-08-16T07:06:26.578Z","level":"INFO","request_id":"req-abc123","trace_id":"3120189d...","span_id":"41082254...","message":"inside span"}
```

ジョブなどリクエスト外のログ:
```json
{"time":"2026-08-16T07:06:26.578Z","level":"INFO","tags":["ActiveJob","SqsAdapter"],"message":"job log"}
```

## 実装タスク

- [x] `Gemfile` に `lograge` を追加し `bundle install`（lograge 0.15.0 / request_store 1.7.0）
- [x] `lib/logging/json_log_formatter.rb` を追加（JSONフォーマッタ本体）
  - [x] `Logger::Formatter` 互換の `call` を実装
  - [x] TaggedLogging のタグを文字列前置ではなくフィールドとして扱う（Hashタグ → 名前付き / それ以外 → `tags`）
  - [x] OpenTelemetry の現在スパンから `trace_id` / `span_id` を付与
  - [x] Hash メッセージ（lograge の Raw フォーマッタ）はトップレベルにマージ
  - [x] Exception メッセージは `message` / `error_class` / `backtrace` に展開
  - [x] JSON化に失敗しても例外を出さずフォールバックする（`log_format_error` を付けて出力）
- [x] `config/application.rb` の `autoload_lib` の ignore に `logging` を追加（起動時に require するため）
- [x] `config/environments/production.rb` を更新
  - [x] `config.logger` を JSON フォーマッタ + TaggedLogging 構成に変更
  - [x] `config.log_tags` を Hash を返す Proc に変更
  - [x] `config.lograge` の設定（`enabled` / `formatter` / `custom_options`）
- [x] `config/initializers/otel.rb` で `OpenTelemetry.logger` を Rails ロガーに設定（OTel自身のログもJSON化）
- [x] `spec/lib/logging/json_log_formatter_spec.rb` を追加
- [x] `bundle exec rspec` が通ること（1083 examples, 0 failures, 2 pending）
- [x] `bundle exec rubocop` が通ること（既存の Gemfile の指摘3件のみで、今回の変更分は0件）

## 動作確認
- [x] `RAILS_ENV=production` で起動し、リクエストログが1行1JSONで出ること
- [x] `request_id` / `trace_id` / `span_id` が入っていること
- [x] lograge により `Started GET ...` / `Processing by ...` / `Completed 200 ...` の複数行ログが出なくなること
- [ ] レビューアプリでの動作確認
- [ ] ログ収集基盤（Mackerel等）側でJSONとしてパースされること

## 補足 / 未対応

- `config/initializers/otel.rb` には既存のバグがある。`OTEL_ENDPOINT` 未設定のまま production で起動すると
  `uninitialized constant OpenTelemetry::SDK::Trace::Export::NoOpSpanExporter` で
  `OpenTelemetry::SDK.configure` が失敗する（opentelemetry-sdk 1.10.0 にこの定数は存在しない。
  何もしないエクスポータが必要なら `OpenTelemetry::SDK::Trace::Export::SpanExporter` を使うか、
  そもそも span processor を追加しない）。今回のログ変更とは無関係のため未修正。
