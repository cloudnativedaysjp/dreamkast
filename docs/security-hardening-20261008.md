# セキュリティ修正と反映手順（2026-10-08）

`main` の `2375db3b` から作成した `fix/security-hardening` の変更。WebSocket の接続・チャンネル実装は対象外。

## 修正内容

- 公開セッション検索を整数IDのバインドに変更し、不正な入力を400にする。
- 配信状態・動画登録APIは対象イベントの管理者、または専用scopeを持つM2Mだけに許可する。
- スポンサー管理はイベントとスポンサーへの所属を必須にし、操作対象も同じスポンサーに限定する。担当者の自己登録による権限取得と、別スポンサーの登壇者・セッションの操作を防ぐ。
- 招待承認にはトークン、同一イベント、検証済みメールアドレスの一致、有効期限を要求する。トランザクション内の行ロックと永続的な承認日時で再利用を防ぐ。リクエストから所属や認証IDを変更できないようにする。
- 管理操作、CSV出力、一括更新を対象イベントに限定する。CSVの出力先を利用者の入力から組み立てない。
- アバターはログイン、CSRF検証、10MiB制限、JPEG/PNG/WebPの内容判定を必須にする。
- 動画アップロードは登壇者・管理者に限定し、DBで所有者を管理する。1ファイル5GiB、同時5件、24時間の有効期限、15分のパート署名を設定する。Content-Lengthも署名に含め、完了時にS3の実パート数・サイズを再確認する。
- 本番HTTPS、Secure/HttpOnly/SameSite Cookie、ログイン時のセッション再生成、Host制限、詳細エラーの非公開化を設定する。CSPは互換性確認のためReport-Onlyで導入する。
- Rails 8.1.4、Node.js 22.23.3と修正版の依存へ更新する。本番イメージからNode・node_modules・開発用gemを除き、UID/GID 1000で実行する。
- CIでBundler Audit、Brakeman、JavaScript依存監査、Trivyを実行する。再利用ワークフローをコミットSHAで固定する。

## 反映時に必要な作業

1. 新しいアプリを起動する前に `bundle exec rails db:migrate` を実行する。`multipart_uploads` と3種類の招待の `accepted_at` が追加され、既存の承認レコードがある招待にも日時を記録する。承認レコードが過去に削除されている招待は復元できないため、既存招待を無効化したい場合は再発行する。
2. Auth0のM2M API権限に `update:streamings` / `update:video_registrations` を作成し、対応するサービスクライアントだけへ付与する。既存の広いAPIトークンは更新処理で403になる。人間の利用者は従来の `<EVENT>-Admin` ロールで認可する。
3. 招待先ユーザーのAuth0メール検証を完了する。セッションに `email_verified: true` がない利用者は再ログインする。未検証メールによる招待承認は403になる。
4. 動画アップロードの呼び出し元を更新する。開始時に `size`（バイト数）、`type`、任意の `partSize`（5〜64MiB、既定64MiB）を送る。セッションCookieと更新系リクエストの `X-CSRF-Token` が必要。返却された `partSize` で分割し、各PUTの実バイト数を署名対象のサイズと一致させる。Content-Lengthはブラウザーが設定する。既存のDBに記録されていないアップロードは再開できない。
5. `RAILS_ENV=production bundle exec rails uploads:cleanup` を毎時などで定期実行する。あわせてS3の未完了multipart uploadを削除するライフサイクルを設定する。アプリの30回/分制限はプロセス単位なので、全体の流量制限・リクエストボディ上限は入口のプロキシでも設定する。
6. ヘルスチェックを `/up` に向ける。既定以外のホスト名は `RAILS_ALLOWED_HOSTS` にカンマ区切りで指定する。リバースプロキシでTLSを終端し、コンテナの直接公開を避ける構成を前提としている。
7. UID/GID 1000で `tmp`、`log`、`storage`、`public/uploads` に書き込めることを確認する。コンテナ内でNodeを起動する運用スクリプトがある場合はビルド側へ移す。
8. ステージングでAuth0ログイン、招待、実S3への分割アップロード、画像アップロード、配信APIを確認する。CSPは現時点ではブロックしない。ブラウザーの違反表示を確認し、必要な外部サービスを整理してから強制へ切り替える。

Auth0・S3・プロキシ・スケジューラーの外部設定変更とデプロイは、このブランチでは実行していない。

## 残る依存の指摘

次の2件は監査時点で修正版が未公開。ビルド・開発用の依存であり、本番イメージにはnode_modulesを含めない。リスクがゼロになったことを意味しない。外部から受け取ったglobやformat文字列をビルドCLIへ渡さないこと。

| パッケージ | 指摘 | 管理方法 |
| --- | --- | --- |
| braces | [GHSA-vfj7-8cjw-p6xm](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm) | Chokidar/Micromatch経由。修正版公開時に更新 |
| sprintf-js | [GHSA-hp3w-g68c-fv3c](https://github.com/advisories/GHSA-hp3w-g68c-fv3c) | Argparse経由。修正版公開時に更新 |

例外は `config/javascript-audit-exceptions.json` に限定して記録し、2026-11-08に失効する。新しい指摘、監査エラー、期限切れはCIを失敗させる。Brakemanの除外4件は生成済みの一時ファイル等に対する誤検知として理由を `config/brakeman.ignore` に記録している。CIはHigh/Medium confidenceを対象とし、Weak confidenceの指摘は別途レビュー対象とする。

## 検証範囲

RSpecは本番から独立した一時MySQLで実行し、S3・Auth0の外部呼び出しはテスト用に置き換える。パート署名は実SDKでContent-Lengthが署名対象になることも確認する。実S3との疎通試験は含まない。

Docker/WSL連携がこの環境では利用できないため、Dockerイメージのビルドとコンテナ起動は未検証。反映前にCIで確認する。各コマンドの結果は `docs/todo/security-hardening-20261008.md` に記録する。
