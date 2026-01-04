# MySQL 8.4 LTSアップグレード チェックリスト

## プロジェクト概要

DreamkastプロジェクトのMySQL 8.0を**MySQL 8.4.7 LTS**にアップグレードします。

**スケジュール**: 1-2週間以内の完了を目指す急ぎの対応

**本番環境**: AWS RDS for MySQL (Terraform管理)
**アップグレード方式**: RDSメジャーバージョンアップグレード機能
**ターゲットバージョン**: MySQL 8.4.7 (RDS最新LTS版)

## ⚠️ 重要: MySQL 8.4 LTSについて

**AWS CLI調査結果**: RDSではMySQL 9.xは現時点で利用不可であることを確認しました。

- **RDS利用可能な最新バージョン**: MySQL 8.4.7 (LTS)
- **確認コマンド結果**:
  ```
  8.0.44 (8.0系最新)
  8.4.7  (8.4系最新・LTS)
  MySQL 9.x系は0件
  ```

**MySQL 8.4 LTSを選択する理由**:
- 長期サポート (LTS) 保証
- MySQL 8.0から8.4への移行はメジャーバージョンアップだが、9.0よりリスクが低い
- 認証方式: mysql_native_password は非推奨だが引き続きサポート (後方互換性あり)
- utf8mb4_0900_ai_ci照合順序は8.0から継続サポート

---

## Phase 1: 事前調査 ✅ (完了)

### AWS RDS MySQL 8.4対応状況確認

- [x] ✅ RDSでMySQL 8.4が利用可能か確認 - **確認完了**
  - **結果**: MySQL 8.4.7 (LTS) がProduction環境で利用可能
  - **確認コマンド**:
    ```bash
    aws rds describe-db-engine-versions \
      --engine mysql \
      --region ap-northeast-1 \
      --query "DBEngineVersions[].[EngineVersion,Status]" \
      --output table
    ```
  - **利用可能バージョン**: 8.0.44, 8.4.7

### mysql2 gem互換性確認

- [x] ✅ 最新バージョン確認 - **0.5.7が最新**
  ```bash
  gem list mysql2 --remote --all | grep mysql2
  ```
- [ ] GitHubでMySQL 8.4対応状況確認
  - https://github.com/brianmario/mysql2/issues
  - https://github.com/brianmario/mysql2/blob/master/CHANGELOG.md
- [ ] Ruby 3.3.8 (現在のバージョン) との互換性確認
- [ ] mysql2 0.5.7がMySQL 8.4.7で動作することを開発環境で確認

**調査結果**: mysql2 gemは0.5.6→0.5.7へのアップデートで十分な可能性が高い

---

## Phase 2: 開発環境の更新 (1-2日)

### Gemfileの更新
- [ ] [Gemfile:72](Gemfile#L72) を更新
  ```ruby
  # 変更前
  gem "mysql2", "~> 0.5.6"

  # 変更後
  gem "mysql2", "~> 0.5.7"
  ```
- [ ] `bundle update mysql2` 実行
- [ ] `Gemfile.lock` の変更確認
- [ ] `bundle install` 実行

### Docker Compose設定の更新
- [ ] [compose.yaml:57-66](compose.yaml#L57-L66) を更新
  ```yaml
  # 変更前
  db:
    image: mysql/mysql-server:8.0
    command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_0900_ai_ci --default-authentication-plugin=mysql_native_password

  # 変更後
  db:
    image: mysql/mysql-server:8.4
    command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_0900_ai_ci --authentication-policy=caching_sha2_password
  ```
  **注**: `--authentication-policy=caching_sha2_password` を推奨するが、`mysql_native_password` も引き続き動作

### devbox設定の更新
- [ ] [devbox.json:11](devbox.json#L11) を確認
  - `mysql80` → `mysql84` へ変更可能か確認
  ```bash
  devbox search mysql
  ```
- [ ] mysql84パッケージが存在する場合のみ更新
  ```json
  {
    "packages": [
      "mysql84@latest"
    ]
  }
  ```
- [ ] `devbox update` 実行

**注**: devboxでmysql84が利用できない場合、mysql80のままでも問題なし（開発環境用）

### 初期化スクリプトの更新
- [ ] [db/docker-entrypoint-initdb.d/1_allow-host-ip.sql](db/docker-entrypoint-initdb.d/1_allow-host-ip.sql) を更新
  ```sql
  -- MySQL 8.4対応: 認証プラグインを明示的に指定 (caching_sha2_password推奨)
  CREATE USER IF NOT EXISTS root@'%' IDENTIFIED WITH caching_sha2_password BY 'root';
  GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
  ```

  **代替案** (mysql_native_passwordでも動作):
  ```sql
  CREATE USER IF NOT EXISTS root@'%' IDENTIFIED WITH mysql_native_password BY 'root';
  GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
  ```

### Dockerfileの確認
- [ ] [Dockerfile:13](Dockerfile#L13) のMySQLクライアントライブラリ確認
  - 現在: `libmariadb3`
  - MySQL 8.4で動作確認
  - 必要に応じて `default-libmysqlclient-dev` への変更を検討

---

## Phase 3: 開発環境でのテスト (2日)

### クリーン環境でのDB初期化テスト
- [ ] 既存データ削除
  ```bash
  docker compose down -v
  ```
- [ ] MySQL 8.4で起動
  ```bash
  docker compose up -d db redis localstack nginx ui fifo-worker
  ```
- [ ] DBログ確認 (MySQL 8.4起動確認)
  ```bash
  docker compose logs db | head -20
  ```
- [ ] DB初期化
  ```bash
  bundle exec rails db:create
  bundle exec rails db:migrate
  bundle exec rails db:seed_fu
  ```
- [ ] マイグレーション全て成功確認
- [ ] 外部キー制約作成成功確認
- [ ] シードデータ投入成功確認
- [ ] 接続エラーなし確認

### RSpecテストスイート実行
- [ ] テスト環境準備
  ```bash
  RAILS_ENV=test bundle exec rails db:drop
  RAILS_ENV=test bundle exec rails db:create
  RAILS_ENV=test bundle exec rails db:migrate
  ```
- [ ] 全テスト実行
  ```bash
  bundle exec rspec
  ```
- [ ] ✅ 全テスト100%パス確認
- [ ] テスト失敗時の原因調査とフィックス

### devbox環境でのテスト
- [ ] devbox環境で起動 (mysql84パッケージ利用時)
  ```bash
  devbox shell
  bin/devbox-auth.sh
  bin/devbox-start.sh
  ```
- [ ] 動作確認

### 手動統合テスト
- [ ] Auth0認証機能の動作確認
- [ ] JSON型カラム操作 (proposal_items.params等)
- [ ] 日本語データ検索 (照合順序依存: utf8mb4_0900_ai_ci, utf8mb4_unicode_ci)
- [ ] 外部キー制約の動作確認
- [ ] トランザクション処理の確認
- [ ] バックグラウンドジョブ (Sidekiq) の動作確認

---

## Phase 4: CI/CD環境の確認 (0.5日)

### GitHub Actions動作確認
- [ ] ローカルでCI環境再現
  ```bash
  docker compose up -d db redis
  bundle exec rails db:create RAILS_ENV=test
  bundle exec rails db:migrate RAILS_ENV=test
  bundle exec rspec
  ```
- [ ] GitHub ActionsでのCI実行成功確認
  - `.github/workflows/` 配下のワークフロー確認
  - MySQL 8.4イメージ指定が必要か確認

### Dockerビルド確認
- [ ] 本番環境デプロイ用Dockerイメージのビルド成功確認
  ```bash
  docker build -t dreamkast:mysql84-test .
  ```
- [ ] ビルドログでMySQL関連エラーなし確認

---

## Phase 5: Terraform設定の更新 (1日)

### Terraformリポジトリの特定
- [ ] Terraformコードの場所を特定
  - 同一リポジトリ内の `terraform/` ディレクトリ
  - または別リポジトリ (dreamkast-infra等)
- [ ] RDS設定ファイルの特定
  - `terraform/rds.tf` または `terraform/modules/rds/main.tf`
- [ ] パラメータグループ設定ファイルの確認

### Terraform設定の更新
- [ ] RDSエンジンバージョン更新
  ```hcl
  # 変更前
  engine_version = "8.0.35"  # または現在のバージョン

  # 変更後
  engine_version = "8.4.7"
  ```

- [ ] パラメータグループの更新
  ```hcl
  # 変更前
  parameter_group_name = "default.mysql8.0"

  # 変更後
  parameter_group_name = aws_db_parameter_group.mysql84.name
  ```

- [ ] カスタムパラメータグループ作成 (必要に応じて)
  ```hcl
  resource "aws_db_parameter_group" "mysql84" {
    name   = "dreamkast-mysql84"
    family = "mysql8.4"

    parameter {
      name  = "character_set_server"
      value = "utf8mb4"
    }

    parameter {
      name  = "collation_server"
      value = "utf8mb4_0900_ai_ci"
    }

    parameter {
      name  = "authentication_policy"
      value = "caching_sha2_password"
    }
  }
  ```

### Terraform plan実行
- [ ] `terraform init` 実行 (必要に応じて)
- [ ] ステージング環境でplan実行
  ```bash
  cd terraform/
  terraform workspace select staging  # または環境に応じた選択
  terraform plan -out=mysql84-upgrade-staging.plan
  ```
- [ ] 変更内容の確認
  - RDSエンジンバージョン: 8.0.x → 8.4.7
  - パラメータグループ: mysql8.0 → mysql8.4
  - その他のリソース変更なし確認

**⚠️ 重要**: この段階では `terraform apply` は実行しません

---

## Phase 6: ステージング環境での検証 (3-4日)

### ステージング環境のRDSアップグレード準備
- [ ] ステージング環境の手動スナップショット作成
  ```bash
  aws rds create-db-snapshot \
    --db-instance-identifier dreamkast-staging \
    --db-snapshot-identifier dreamkast-staging-pre-mysql84-$(date +%Y%m%d-%H%M)
  ```
- [ ] スナップショット完成待機 (10-30分)
  ```bash
  aws rds describe-db-snapshots \
    --db-snapshot-identifier dreamkast-staging-pre-mysql84-$(date +%Y%m%d-%H%M) \
    --query 'DBSnapshots[0].Status'
  ```
- [ ] ダウンタイム通知 (チーム内通知)

### ステージング環境のRDSアップグレード実行
- [ ] Terraformでステージング環境のRDSをアップグレード
  ```bash
  cd terraform/
  terraform workspace select staging
  terraform apply mysql84-upgrade-staging.plan
  ```
- [ ] アップグレード完了待機 (20-40分)
- [ ] RDSステータス確認
  ```bash
  aws rds describe-db-instances \
    --db-instance-identifier dreamkast-staging \
    --query 'DBInstances[0].[DBInstanceStatus,EngineVersion]'
  ```
  期待値: `["available", "8.4.7"]`

### アップグレード後の確認
- [ ] RDSイベントログ確認
  ```bash
  aws rds describe-events \
    --source-identifier dreamkast-staging \
    --source-type db-instance \
    --duration 60
  ```
- [ ] CloudWatch メトリクス確認
  - DatabaseConnections
  - CPUUtilization
  - FreeableMemory
- [ ] アプリケーションログ確認 (ECS Logs)

### アプリケーションの動作確認
- [ ] アプリケーション起動成功
- [ ] 認証機能 (Auth0ログイン)
- [ ] CRUD操作全般
  - プロポーザル作成・編集・削除
  - トーク作成・編集・削除
  - スピーカー登録・編集
- [ ] JSON型カラム操作 (proposal_items.params等)
- [ ] バックグラウンドジョブ (SQS経由)
- [ ] ファイルアップロード (S3連携)
- [ ] 検索機能 (日本語)

### パフォーマンステスト
- [ ] 主要APIエンドポイントのレスポンスタイム計測
  - GET /api/v1/talks
  - GET /api/v1/proposals
  - POST /api/v1/proposals
- [ ] データベースクエリ実行時間計測
  - スロークエリログ確認
- [ ] 接続確立時間計測
- [ ] ✅ MySQL 8.0との差異±15%以内確認

### 安定稼働確認 (最低3日間)
- [ ] エラーログ監視 (アプリケーション + RDS)
- [ ] スロークエリログ監視
- [ ] 接続エラー数監視
- [ ] レスポンスタイム監視
- [ ] データ整合性確認

---

## Phase 7: 本番環境へのアップグレード (1日 + 監視1週間)

### 本番環境アップグレード前の準備 (アップグレード3日前)
- [ ] 完全バックアップ (手動スナップショット) 作成
  ```bash
  aws rds create-db-snapshot \
    --db-instance-identifier dreamkast-production \
    --db-snapshot-identifier dreamkast-prod-pre-mysql84-$(date +%Y%m%d)
  ```
- [ ] スナップショット完成確認 (30-60分)
- [ ] ロールバック計画作成
  - RDSスナップショットからの復元手順
  - DNSカットバック手順 (Route53変更)
  - データ損失時の対応手順
  - ロールバックに要する時間: 30-60分
- [ ] メンテナンス通知 (ユーザーへの事前通知)
  - 対象: 全ユーザー
  - 内容: MySQL 8.4アップグレードに伴うメンテナンス
  - ダウンタイム: 約30-60分
  - メンテナンスウィンドウ: 深夜帯 (例: 3:00-5:00 JST)

### 本番環境Terraformプラン準備
- [ ] 本番環境でterraform plan実行
  ```bash
  cd terraform/
  terraform workspace select production
  terraform plan -out=mysql84-upgrade-production.plan
  ```
- [ ] 変更内容の最終確認
- [ ] 実行タイミング合意 (チーム全体)

### 本番環境アップグレード実行 (深夜作業)
- [ ] アプリケーション停止 (ECSタスク数を0に)
  ```bash
  aws ecs update-service \
    --cluster dreamkast-production \
    --service dreamkast-app \
    --desired-count 0
  ```
- [ ] アプリケーション完全停止確認 (3-5分)
- [ ] RDSアップグレード実行
  ```bash
  cd terraform/
  terraform workspace select production
  terraform apply mysql84-upgrade-production.plan
  ```
- [ ] アップグレード完了待機 (30-60分)
- [ ] 接続テスト
  ```bash
  mysql -h <rds-endpoint> -u <user> -p -e "SELECT VERSION();"
  # 期待値: 8.4.7
  ```
- [ ] アプリケーション再起動
  ```bash
  aws ecs update-service \
    --cluster dreamkast-production \
    --service dreamkast-app \
    --desired-count 2  # または元のタスク数
  ```

### 本番環境動作確認 (即時)
- [ ] アプリケーション起動確認 (ECSタスクHealthy)
- [ ] ヘルスチェックエンドポイント確認
  ```bash
  curl https://dreamkast.example.com/health
  ```
- [ ] ログイン機能確認 (Auth0)
- [ ] 主要機能の動作確認
  - トーク一覧表示
  - プロポーザル作成
  - ファイルアップロード
- [ ] エラーログ確認 (CloudWatch Logs)
- [ ] データベース接続エラーなし確認

### 継続監視 (1週間)
- [ ] 1日目: 頻繁に監視 (1時間おき)
- [ ] 2-3日目: 定期監視 (3時間おき)
- [ ] 4-7日目: 通常監視 (1日1回)

**監視項目**:
- [ ] CloudWatch ダッシュボード監視
  - RDS CPUUtilization
  - RDS DatabaseConnections
  - RDS ReadLatency / WriteLatency
- [ ] アプリケーションログ監視 (エラー率)
- [ ] ユーザーからの問い合わせ監視
- [ ] レスポンスタイム監視 (APM)

---

## ロールバック判断基準

### 即時ロールバック条件 (アップグレード後30分以内)
- アプリケーション起動失敗
- データベース接続エラー連続発生 (5分以上)
- クリティカルな機能不全 (ログイン不可等)

### 段階的ロールバック条件 (1週間以内)
- エラー率 > 1% (通常の2倍以上)
- レスポンスタイム 2倍以上悪化
- データ不整合検出
- ユーザークレーム多数

### ロールバック手順
1. アプリケーション停止 (ECSタスク数0)
2. RDSスナップショットから復元
3. 復元完了待機 (30-60分)
4. アプリケーション起動
5. 動作確認

---

## 変更対象ファイル一覧

### アプリケーションコード
1. [Gemfile:72](Gemfile#L72) - mysql2 gemバージョン: 0.5.6 → 0.5.7
2. [compose.yaml:57-66](compose.yaml#L57-L66) - MySQLイメージ: 8.0 → 8.4、認証設定変更
3. [devbox.json:11](devbox.json#L11) - MySQL package: mysql80 → mysql84 (オプション)
4. [db/docker-entrypoint-initdb.d/1_allow-host-ip.sql](db/docker-entrypoint-initdb.d/1_allow-host-ip.sql) - 認証プラグイン明示的指定
5. [Dockerfile:13](Dockerfile#L13) - MySQLクライアントライブラリ確認 (変更不要の可能性)

### インフラストラクチャコード
6. `terraform/rds.tf` (または `terraform/modules/rds/main.tf`) - RDSエンジンバージョン、パラメータグループ
7. `terraform/parameter_groups.tf` (新規作成の可能性) - MySQL 8.4パラメータグループ

### CI/CD設定 (必要に応じて)
8. `.github/workflows/*.yml` - GitHub ActionsでのMySQL 8.4イメージ指定

---

## リスクと緩和策

### 高リスク
| リスク | 影響 | 緩和策 |
|--------|------|--------|
| 本番アップグレード失敗 | サービス停止 | 完全バックアップ + ロールバック計画 + 深夜メンテナンス |
| mysql2 gem非互換 | アプリ起動失敗 | 開発環境で事前テスト (Phase 3) |
| データ破損 | データ損失 | スナップショット作成 + 復元テスト |

### 中リスク
| リスク | 影響 | 緩和策 |
|--------|------|--------|
| パフォーマンス劣化 | ユーザー体験悪化 | ステージング環境でベンチマーク (Phase 6) |
| 認証エラー | 接続失敗 | 開発環境で認証方式テスト (Phase 3) |
| 照合順序の挙動変化 | 検索結果の差異 | 日本語データ検索テスト (Phase 3) |

### 低リスク
| リスク | 影響 | 緩和策 |
|--------|------|--------|
| CI/CDパイプライン失敗 | デプロイ遅延 | Phase 4でGitHub Actions確認 |
| Dockerビルド失敗 | 開発環境構築不可 | Phase 4でビルド確認 |

---

## 成功基準

- [ ] 開発環境でRSpec全テスト成功 (Phase 3)
- [ ] CI/CDパイプライン成功 (Phase 4)
- [ ] ステージング環境で3日間以上安定稼働 (Phase 6)
- [ ] 本番環境でエラー率変化なし (±0.1%以内)
- [ ] パフォーマンス±15%以内 (レスポンスタイム、クエリ実行時間)
- [ ] ユーザーからのクレームなし
- [ ] データ不整合なし

---

## タイムライン (1-2週間)

| 期間 | フェーズ | 担当 | 成果物 |
|------|---------|------|--------|
| 1日目 | Phase 1: 事前調査 ✅ | エンジニア | RDS対応確認、gem互換性確認 |
| 2-3日目 | Phase 2: 開発環境更新 | エンジニア | Gemfile、compose.yaml、devbox.json更新 |
| 4-5日目 | Phase 3: 開発環境テスト | エンジニア + QA | RSpec全テスト成功 |
| 6日目 | Phase 4: CI/CD確認 | エンジニア | GitHub Actions成功 |
| 7日目 | Phase 5: Terraform更新 | インフラエンジニア | Terraform plan作成 |
| 8-11日目 | Phase 6: ステージング検証 | エンジニア + QA | 3日間安定稼働確認 |
| 12日目 | Phase 7準備 | 全員 | 本番plan、ロールバック計画 |
| 13日目深夜 | Phase 7: 本番アップグレード | 全員 (深夜作業) | 本番MySQL 8.4化完了 |
| 14-20日目 | 継続監視 | 運用チーム | 1週間安定稼働確認 |

---

## 重要な発見事項

### 現在の構成
- **開発環境**: Docker Compose (MySQL 8.0) + devbox (mysql80)
- **本番環境**: AWS RDS for MySQL 8.0 (Terraform管理)
- **mysql2 gem**: 0.5.6 (0.5.7へアップデート推奨)
- **認証方式**: mysql_native_password (8.4でも動作するが非推奨)
- **文字コード**: utf8mb4 / 照合順序混在 (utf8mb4_unicode_ci, utf8mb4_0900_ai_ci)

### MySQL 8.4での主要変更点
1. **mysql_native_password**: 非推奨だが引き続き動作 (後方互換性あり)
   - 推奨: caching_sha2_password への移行
   - 緊急性: 低 (8.4では動作する)

2. **utf8mb4_0900_ai_ci**: 8.0から継続サポート
   - 現在の照合順序はそのまま使用可能

3. **パフォーマンス改善**: 8.4ではクエリオプティマイザが改善
   - 一部クエリで高速化の可能性

4. **セキュリティ強化**: 認証機能の強化
   - caching_sha2_password が推奨

---

## 次のアクション (優先順位順)

1. **Phase 2開始**: 開発環境の更新
   - Gemfile更新 (mysql2: 0.5.6 → 0.5.7)
   - compose.yaml更新 (MySQL 8.0 → 8.4)
   - devbox.json確認 (mysql84パッケージの有無確認)

2. **Phase 3開始**: 開発環境でのテスト
   - クリーン環境でのDB初期化
   - RSpecテストスイート実行

3. **Terraformリポジトリの特定**
   - RDS設定ファイルの場所確認
   - パラメータグループ設定確認

4. **ステークホルダーへの事前通知**
   - アップグレード計画の共有
   - メンテナンスウィンドウの調整

5. **ロールバック計画の詳細化**
   - スナップショット復元手順の文書化
   - ロールバックリハーサル (ステージング環境)

---

## 参考リンク

- [MySQL 8.4 Release Notes](https://dev.mysql.com/doc/relnotes/mysql/8.4/en/)
- [AWS RDS MySQL 8.4 Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.VersionMgmt.html)
- [mysql2 gem GitHub](https://github.com/brianmario/mysql2)
- [MySQL 8.0 to 8.4 Upgrade Guide](https://dev.mysql.com/doc/refman/8.4/en/upgrading-from-previous-series.html)
