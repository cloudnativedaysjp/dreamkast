# Ruby

rbenvを使ってRubyのバージョンを管理しています。

# 開発プロセス

docs/todo以下にタスク毎のチェックリストを作成氏、それに従って作業を進める。作業が完了したらチェックリストもチェックすること。

以下のコマンドを使って動作確認してください。テストとリントは通すこと。

依存ミドルウェアの起動

```
DOCKER_BUILDKIT=1 docker compose up db redis nginx localstack
```

テスト

```
bundle exec rspec
```

リント

```
bundle exec rubocop --autocorrect-all
```
