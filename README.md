# dreamkast

<div align="center">
<img src="docs/images/dreamkast.png" width="300">
</div>

Ruby on Railsで構築されたオンラインカンファレンスシステム

## Dreamkastプラットフォームについて

詳細は[Notion](https://www.notion.so/cloudnativedays/Dreamkast-Team-bc787244afdc45b880c014bd61891aa8)を参照してください（メンバー限定）

## 前提条件

- OS: macOS, Linux, Windows
- **Docker**

## 開発環境のセットアップ

**devbox**を使用すると、チーム全体で統一された開発環境を簡単にセットアップできます。

### devboxの利点

- **統一された開発環境**: チーム全体で同じバージョンのツールを使用
- **簡単なセットアップ**: rbenv/nodenvの手動インストールが不要
- **再現性の保証**: devbox.lockでバージョンを固定
- **AWS認証情報の自動取得**: Secrets Managerから認証情報を自動で取得

**注意**: Node.jsはdevboxが提供する22系の安定版を使用します（.node-versionでは22.16.0を指定していますが、devboxでは`nodejs@22`で22系の安定バージョンを自動取得）。マイナーバージョンの違いはありますが互換性があるため、開発に支障はありません。

### クイックスタート

```bash
# 1. devboxのインストール
curl -fsSL https://get.jetify.com/devbox | bash

# 2. リポジトリのクローン
git clone https://github.com/cloudnativedaysjp/dreamkast.git
cd dreamkast

# 3. devbox環境の初期化
devbox shell

# 4. 初回セットアップ（依存関係インストール）
devbox run setup

# 5. AWS認証とシークレット取得
devbox run auth

# 6. アプリケーション起動
devbox run start
```

ブラウザで `http://localhost:8080` にアクセスしてください。

### セットアップの詳細

#### 1. devboxのインストール

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

詳細: <https://www.jetify.com/devbox/docs/installing_devbox/>

#### 2. devbox環境の初期化

```bash
devbox shell
```

初回実行時、必要なパッケージ(Ruby、Node.js、Docker等)が自動ダウンロードされます(5-10分程度)。

#### 3. 初回セットアップ

```bash
devbox run setup
```

このコマンドは以下を実行します:

- 環境変数テンプレート(`.env-local.devbox.example`)のコピー
- `yarn install --check-files`
- `bundle install`

#### 4. AWS認証とシークレット取得

```bash
devbox run auth
```

このコマンドは以下を自動的に実行します:

- AWS SSO設定の自動構成（SSO Start URLを含む）
- AWS SSOログイン（ブラウザで認証）
- ECRログイン
- AWS Secrets Managerから認証情報を自動取得
  - Auth0設定(CLIENT_ID, CLIENT_SECRET, DOMAIN)
  - Rails Master Key

**注意**: 初回実行時はブラウザでAWS SSOの認証が求められます。Dreamkastチームから付与されたAWSアカウントでログインしてください。

**リモート環境での認証**: リモート環境（SSH接続先など）でブラウザが開けない場合は、環境変数`DEVBOX_REMOTE=1`を使用します:

```bash
DEVBOX_REMOTE=1 devbox run auth
```

このコマンドは認証URLとコードを表示するので、手元のブラウザで開いて認証を完了してください。

#### 5. アプリケーション起動

```bash
devbox run start
```

このコマンドは以下を実行します:

- Docker Composeサービスの起動（db, redis, localstack, nginx, ui, fifo-worker）
- データベースマイグレーション（`rails db:migrate`）
- シードデータ投入（`rails db:seed`）
- Railsアプリケーションの起動

ブラウザで `http://localhost:8080` にアクセスしてください。

**注意**: PC起動後は毎回`devbox run start`を実行してください。このコマンドでDockerコンテナが起動します。

### 日常の開発フロー

#### アプリケーション起動

```bash
devbox shell
devbox run start
```

#### テスト実行

```bash
devbox shell
devbox run test
```

または個別テスト:

```bash
bundle exec rspec spec/models/talk_spec.rb
```

#### Lint実行

```bash
bundle exec rubocop --autocorrect-all
```

#### データベース操作

マイグレーション:

```bash
bundle exec rails db:migrate
```

シードデータ投入:

```bash
bundle exec rails db:seed
```

#### Docker Composeサービスの管理

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

### トラブルシューティング

#### devbox shellが遅い

初回実行時はパッケージダウンロードで時間がかかります。2回目以降はキャッシュが効くため高速です。

#### MySQL接続エラー

```bash
# DBサービスの状態確認
docker compose ps db

# DBログ確認
docker compose logs db

# DB再起動
docker compose restart db
```

#### yarn installエラー

```bash
# node_modules削除
rm -rf node_modules

# 再インストール
yarn install --check-files
```

#### bundle installエラー

```bash
# vendor/bundle削除
rm -rf vendor/bundle

# 再インストール
bundle install
```

#### ECRログインエラー

```bash
# AWS SSOセッションの更新
aws sso login --profile dreamkast

# ECRログイン再実行
devbox run auth
```

#### Secrets Manager取得エラー

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

#### Rails起動時のRAILS_MASTER_KEYエラー

`.env-local.devbox`にRAILS_MASTER_KEYが設定されているか確認してください。

```bash
# 設定確認
grep RAILS_MASTER_KEY .env-local.devbox

# 未設定の場合は再取得
devbox run fetch-secrets
```

## その他のセットアップ方法

devboxを使わない場合の代替セットアップ方法:

- [Docker Composeを使ったセットアップ](docs/SETUP_DOCKER_COMPOSE.md) - 最速でセットアップしたい場合
- [ローカル環境を使ったセットアップ](docs/SETUP_LOCAL.md) - rbenv/nodenvを使った従来方式

## 高度な機能

- [Ruby型定義（RBS）とVideoRegistration API](docs/ADVANCED.md)

## rubocopの自動実行

```bash
git config pre-commit.ruby "bundle exec ruby"
git config pre-commit.checks "[rubocop]"
```

## 参考リンク

- [devbox公式ドキュメント](https://www.jetify.com/devbox/docs/)
- [Dreamkast AGENT.md](AGENT.md)
