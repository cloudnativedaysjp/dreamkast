# Dreamkast開発環境セットアップ (devbox版)

## 概要

devboxを使用することで、以下の利点があります:

- **統一された開発環境**: チーム全体で同じバージョンのツールを使用
- **簡単なセットアップ**: rbenv/nodenvの手動インストールが不要
- **再現性の保証**: devbox.lockでバージョンを固定

## 前提条件

- macOS、Linux、WSL2のいずれか
- Dockerのインストール(Docker Desktop推奨)
- devboxのインストール

### devboxのインストール

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

詳細: <https://www.jetify.com/devbox/docs/installing_devbox/>

## セットアップ手順

### 1. リポジトリクローン

```bash
git clone https://github.com/cloudnativedaysjp/dreamkast.git
cd dreamkast
```

### 2. devbox環境の初期化

```bash
devbox shell
```

初回実行時、必要なパッケージ(Ruby、Node.js、Docker等)が自動ダウンロードされます(5-10分程度)。

### 3. 初回セットアップ

```bash
devbox run setup
```

このコマンドは以下を実行します:

- 環境変数テンプレート(`.env-local.devbox.example`)のコピー
- yarn install --check-files
- bundle install
- Docker Composeサービスの起動
- 健全性チェック

### 4. AWS認証

```bash
devbox run auth
```

このコマンドは以下を実行します:

- AWS SSO設定(初回のみ、対話的に設定)
- AWS SSOログイン
- ECRログイン

初回実行時は、以下の情報をDreamkastチームから取得してください:

- SSO start URL
- SSO region: `ap-northeast-1`
- SSO registration scopes: `sso:account:access`

### 5. 認証情報の自動取得

```bash
devbox run fetch-secrets
```

このコマンドは、AWS Secrets Managerから以下の認証情報を自動取得し、`.env-local.devbox`に設定します:

- Auth0設定(CLIENT_ID, CLIENT_SECRET, DOMAIN)
- Rails Master Key

### 6. アプリケーション起動

```bash
devbox run start
```

ブラウザで <http://localhost:8080> にアクセス。

## 日常の開発フロー

### アプリケーション起動

```bash
devbox shell
devbox run start
```

### テスト実行

```bash
devbox shell
devbox run test
```

または個別テスト:

```bash
bundle exec rspec spec/models/talk_spec.rb
```

### Lint実行

```bash
bundle exec rubocop --autocorrect-all
```

### データベース操作

マイグレーション:

```bash
bundle exec rails db:migrate
```

シードデータ投入:

```bash
bundle exec rails db:seed
```

### Docker Composeサービスの管理

サービス一覧:

```bash
docker compose ps
```

ログ確認:

```bash
docker compose logs -f db
```

サービス再起動:

```bash
docker compose restart db
```

## トラブルシューティング

### devbox shellが遅い

初回実行時はパッケージダウンロードで時間がかかります。2回目以降はキャッシュが効くため高速です。

### MySQL接続エラー

```bash
# DBサービスの状態確認
docker compose ps db

# DBログ確認
docker compose logs db

# DB再起動
docker compose restart db
```

### yarn installエラー

```bash
# node_modules削除
rm -rf node_modules

# 再インストール
yarn install --check-files
```

### bundle installエラー

```bash
# vendor/bundle削除
rm -rf vendor/bundle

# 再インストール
bundle install
```

### ECRログインエラー

```bash
# AWS SSOセッションの更新
aws sso login --profile dreamkast

# ECRログイン再実行
devbox run auth
```

### Secrets Manager取得エラー

```bash
# AWS認証状態確認
aws sts get-caller-identity --profile dreamkast

# Secrets Managerへのアクセス権限確認
aws secretsmanager describe-secret \
  --secret-id dreamkast/reviewapp-env \
  --region us-west-2 \
  --profile dreamkast
```

アクセス権限がない場合は、Dreamkastチームに権限付与を依頼してください。

### Rails起動時のRAILS_MASTER_KEYエラー

`.env-local.devbox`にRAILS_MASTER_KEYが設定されているか確認してください。

```bash
# 設定確認
grep RAILS_MASTER_KEY .env-local.devbox

# 未設定の場合は再取得
devbox run fetch-secrets
```

## 既存方式との比較

### devbox版(推奨)

**利点**:

- セットアップが簡単(`devbox run setup`のみ)
- チーム全体で環境が統一される
- rbenv/nodenvの手動管理が不要
- AWS認証情報の自動取得

**欠点**:

- 初回ダウンロードに時間がかかる
- devboxの習得コスト

### Docker Compose全体版(compose-dev.yaml)

**利点**:

- 最速でセットアップ可能
- ホストマシンへの依存が少ない

**欠点**:

- カスタマイズ性が低い
- アプリケーション変更時に再ビルドが必要

### rbenv/nodenv版(従来方式)

**利点**:

- 細かいカスタマイズが可能
- rbenv/nodenvに慣れている場合は使いやすい

**欠点**:

- セットアップが複雑(rbenv、nodenv、shared-mime-info等を個別インストール)
- バージョン管理が手動
- AWS認証情報の手動設定が必要

## 参考リンク

- [devbox公式ドキュメント](https://www.jetify.com/devbox/docs/)
- [Dreamkast README.md](../README.md)
- [Dreamkast AGENT.md](../AGENT.md)
