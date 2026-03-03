# Docker Composeを使ったセットアップ

最も早くセットアップしたい場合は、Docker Composeでアプリケーション全体をコンテナ化する方法が便利です。

## 利点

- 最速でセットアップ可能
- ホストマシンへの依存が少ない

## 欠点

- カスタマイズ性が低い
- アプリケーション変更時に再ビルドが必要

## セットアップ手順

### 1. ECR認証情報の取得

```bash
# AWS SSOでログインし、ECR認証情報を取得
# GAFA アカウントへのアクセス権がない場合や、AWS SSOの使い方が不明な場合はDreamkastチームに問い合わせてください
aws configure sso
aws ecr get-login-password --region ap-northeast-1 --profile dreamkast-core-XXXXX | docker login --username AWS --password-stdin https://607167088920.dkr.ecr.ap-northeast-1.amazonaws.com
```

### 2. `.env`ファイルの作成

以下は例です:

```bash
tee .env <<EOF
AUTH0_CLIENT_ID=
AUTH0_CLIENT_SECRET=
AUTH0_DOMAIN=
SENTRY_DSN=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=ap-northeast-1
DREAMKAST_API_ADDR="http://localhost:8080"
S3_BUCKET=dreamkast-test-bucket
S3_REGION=
MYSQL_HOST=db
MYSQL_USER=root
MYSQL_PASSWORD=root
MYSQL_DATABASE=dreamkast
REDIS_URL=redis://redis:6379
RAILS_MASTER_KEY=
SQS_FIFO_QUEUE_URL=http://localstack:4566/000000000000/default
EOF
```

完全な値が記載されたファイルはDreamkastチームに問い合わせてください。

### 3. Docker Composeで起動

```bash
docker compose -f compose-dev.yaml up -d
```

アプリケーションの起動まで約3分待ちます。

起動後、ブラウザで `http://localhost:8080` にアクセスしてください。

## 参考リンク

- [devboxを使ったセットアップ（推奨）](../README.md)
- [ローカル環境を使ったセットアップ](SETUP_LOCAL.md)
