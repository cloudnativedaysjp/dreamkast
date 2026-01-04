# 高度な機能

このドキュメントでは、Dreamkastの高度な機能について説明します。

## Ruby型定義（RBS）

### Rails用のRBSファイル生成

<https://github.com/pocke/rbs_rails>

Rails（ActiveRecordモデルなど）用のRBSファイルを`sig/rbs_rails/`以下に生成します。これらは自動生成ファイルのため、手動で更新する必要はありません。

```bash
rake rbs_rails:all
```

### アプリケーションコード用のRBSファイル生成

アプリケーションコード用のRBSを生成したい場合は、`rbs prototype`を使用できます。このコマンドはコードからプロトタイプRBSファイルを生成します。生成されたRBSファイルは編集可能です。

```bash
rbs prototype rb ./app/models/access_log.rb > sig/app/models/access_log.rbs
```

## VideoRegistration用のREST API

### Auth0からCLIENT IDとCLIENT SECRETを取得

<https://manage.auth0.com/dashboard/us/dreamkast/applications/Piz0aBnXn0vxesyZScc76PgdCB7lCAbk/settings>

### JWTトークンの生成

```bash
AUTH0_DOMAIN=dreamkast.us.auth0.com
CLIENT_ID=<CLIENT ID>
CLIENT_SECRET=<CLIENT SECRET>
AUDIENCE=https://event.cloudnativedays.jp/
TOKEN=$(curl --url https://${AUTH0_DOMAIN}/oauth/token \
  --header 'content-type: application/json' \
  --data "{\"client_id\":\"${CLIENT_ID}\",\"client_secret\":\"${CLIENT_SECRET}\",\"audience\":\"${AUDIENCE}\",\"grant_type\":\"client_credentials\"}" | jq -r .access_token)
DREAMKAST_DOMAIN='event.cloudnativedays.jp'
```

**注意**: Auth0の制限により、JWTトークンを頻繁に取得しないでください。生成されたトークンは環境変数に保存することを推奨します。生成されたトークンは1日間有効です。

### VideoRegistrationの取得

```bash
curl -X GET -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/1/video_registration
```

### URLの設定

```bash
curl -X PUT -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/1/video_registration -d '{
  "url": "https://foobar"
}'
```

### ビデオステータスの設定

statusには以下の値を設定できます:

- unsubmitted
- submitted
- confirmed
- invalid_format

```bash
curl -X PUT -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/1/video_registration -d '{
  "status": "confirmed",
  "statistics": {
            "file_name": "XX",
            "resolution_status": "OK",
            "resolution_type": "FHD",
            "aspect_status": "OK",
            "aspect_ratio": "16:9",
            "duration_status": "OK",
            "duration_description": "Appropriate media duration.",
            "size_status": "OK",
            "size_description": "Appropriate media size."
          }
}'
```

## 参考リンク

- [メインドキュメント](../README.md)
- [セットアップガイド](SETUP_LOCAL.md)
