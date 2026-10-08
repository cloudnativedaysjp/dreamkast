# セキュリティ修正

起点: main (`2375db3b`)。ブランチ: `fix/security-hardening`。
WebSocket の接続・チャンネル実装は今回の対象外。

- [x] 公開 API の SQL 入力検証と管理 API の認可
- [x] スポンサー管理の所属・所有権確認
- [x] 招待承認のトークン・宛先・期限・再利用防止
- [x] アップロードの認証・CSRF・所有権・容量制限
- [x] イベント単位の管理操作の制限
- [x] HTTPS・セッション・CSP・コンテナの設定
- [x] 修正版のある依存と Rails / Node の更新（未修正2件は期限付き例外）
- [x] CI のセキュリティ監査
- [x] 回帰テスト・既存テスト・lint・依存監査・JS/CSSビルド
- [x] Dockerイメージのビルドと実行（開発設定でのビルド・非rootでのRails起動・foreman起動をローカルで確認）
- [ ] ステージングでのAuth0・S3・TLS終端・非root起動の確認（未デプロイ）

## レビュー指摘への対応

- [x] 登壇者による編集で `conference_id` / `sponsor_id` を受け付けず、カテゴリ・難易度・時間枠をイベント内に限定
- [x] 共同登壇者の招待を自分が登壇するセッションに限定
- [x] CSV出力のファイル名を `<イベント>_<日付>_<トラック>.csv` に戻し、一時ファイルを作らない
- [x] キーノート招待の期限切れ・承諾済みの案内画面を復旧
- [x] RSpec: 1,172 examples、0 failures、既存のpending 2件。Rubocop・Brakeman（Medium以上）指摘なし
- [x] 本番イメージから開発用gem・Node.jsを外す変更を取りやめ、Docker Composeの開発環境（fifo-worker等）が起動しない問題を解消

## 検証結果

- RSpec: 1,166 examples、0 failures、既存のpending 2件。新設したセキュリティ境界テスト57件を含む。
- Jest: 20テスト成功。Node.js 22.23.3で実行。
- Rubocop: 497ファイル、指摘なし。
- Bundler Audit: 最新DB（`b6604fa6`）で該当なし。
- JavaScript監査: 未修正のbraces / sprintf-jsの2件のみ。例外期限は2026-11-08。
- 監査スクリプト: 指摘なし・既知例外は成功し、未知の指摘・不正JSON・通信失敗・空の異常終了は失敗することを6ケースで確認。
- Brakeman: 解析エラー0、High/Medium confidenceの未除外警告0、理由を記載した誤検知の除外4件。Weak confidenceはCIの失敗条件に含めない。
- `yarn install --immutable`、JS/CSSビルド、Railsのテスト用アセット生成: 成功。Webpack/Sassの既存形式由来の警告あり。
- `BUNDLE_WITHOUT=development:test` の本番設定でRails起動・Rakeタスク読み込み成功。CSVの実行時依存を明示し、開発用RBSタスクの読み込みを限定した。
- 本番設定のローカル起動では、未設定のAWS資格情報・OTEL_ENDPOINTに関する既存の警告あり。実サービスとの疎通は未検証。
- `git diff --check`: 問題なし。WebSocketの接続・チャンネル・Cable設定に差分なし。

反映手順と互換性への影響は [修正・反映手順](../security-hardening-20261008.md) を参照。
