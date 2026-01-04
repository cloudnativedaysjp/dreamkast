# ローカル環境を使ったセットアップ（従来方式）

この方法では、ホストマシンに直接Ruby、Node.js、Yarnなどをインストールして開発します。

## 利点

- 細かいカスタマイズが可能
- rbenv/nodenvに慣れている場合は使いやすい

## 欠点

- セットアップが複雑(rbenv、nodenv、shared-mime-info等を個別インストール)
- バージョン管理が手動
- AWS認証情報の手動設定が必要

## 必要なツール

- Ruby
- Node.js
- Yarn
- Docker Compose（MySQLとRedis用）
- AWS CLI

バージョンは `.node-version` と `.ruby-version` ファイルで管理されています。

`nodenv` と `rbenv` を使用してこれらをインストールすることを推奨します。

## セットアップ手順

### 1. 事前準備

shared-mime-infoのインストールが必要です:

- macOS: `brew install shared-mime-info`
- Ubuntu、Debian: `apt-get install shared-mime-info`

### 2. 依存関係のインストール

```bash
yarn install --check-files
bundle install
```

### 3. 環境変数の設定

`.env-local`ファイルを作成し、以下の値を設定してください。正しい値が不明な場合は、Dreamkastチームに問い合わせてください。

```bash
export AUTH0_CLIENT_ID=
export AUTH0_CLIENT_SECRET=
export AUTH0_DOMAIN=
export SENTRY_DSN=
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export S3_BUCKET=
export S3_REGION=
export MYSQL_HOST=db
export MYSQL_USER=user
export MYSQL_PASSWORD=password
export MYSQL_DATABASE=dreamkast
export REDIS_URL=redis://redis:6379
export RAILS_MASTER_KEY=
export SQS_FIFO_QUEUE_URL=http://localhost:9324/queue/default
```

### 4. AWS CLIの設定とECRログイン

```bash
source .env-local
aws ecr get-login-password | docker login --username AWS --password-stdin http://607167088920.dkr.ecr.ap-northeast-1.amazonaws.com/
```

### 5. Docker Composeでバックエンドサービスを起動

```bash
docker compose pull ui
docker compose up -d fifo-worker db redis nginx localstack ui
```

### 6. アプリケーションの起動

```bash
bundle exec foreman start -f Procfile.dev "$@" -e .env
```

## DBマイグレーションとシードデータ投入

```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```

## 参考リンク

- [devboxを使ったセットアップ（推奨）](../README.md)
- [Docker Composeを使ったセットアップ](SETUP_DOCKER_COMPOSE.md)
