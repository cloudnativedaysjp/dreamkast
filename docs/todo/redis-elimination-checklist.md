# Redis完全削除・脱Redis化チェックリスト

## 概要
Rails 8のSolid Cache、Solid Cableを活用し、Redis依存を完全に削除してデータベースベースのアーキテクチャに移行する。
※Solid Queueは現在SQSを使用しているため対象外とする。

## 現状分析

### Redis使用箇所の洗い出し
- [x] セッションストア（`config/initializers/session_store.rb`）
- [x] Action Cable（`config/cable.yml`）
- [x] Docker環境（`compose.yaml`, `compose-dev.yaml`）
- [x] 依存gem（`Gemfile`: redis, redis-session-store）
- [x] 環境変数（`REDIS_URL`）
- [x] ドキュメント（`README.md`, `CLAUDE.md`）
- [x] その他（Sentry breadcrumbs, OpenTelemetry instrumentation）

## 実装フェーズ

### フェーズ1: Solid Cache・Solid Cableのインストール

#### Solid Cache導入
- [x] `bin/rails solid_cache:install`実行
- [x] `config/cache.yml`生成確認
- [x] `db/cache_schema.rb`生成確認
- [x] マイグレーション実行
- [x] `config/environments/production.rb`にキャッシュストア設定追加

#### Solid Cable導入
- [x] `bin/rails solid_cable:install`実行
- [x] `config/cable.yml`をsolid_cableアダプターに更新
- [x] `db/cable_schema.rb`生成確認
- [x] マイグレーション実行

### フェーズ2: セッションストアの移行

#### ActiveRecord Session Store導入
- [x] `activerecord-session_store` gem追加
- [x] `config/initializers/session_store.rb`更新
- [x] セッションテーブル作成（`bin/rails generate active_record:session_migration`）
- [x] マイグレーション実行

### フェーズ3: Redis関連の削除

#### Gem依存関係の削除
- [x] `Gemfile`から`redis`削除
- [x] `Gemfile`から`redis-session-store`削除
- [x] `bundle install`実行
- [x] `Gemfile.lock`更新確認

#### 設定ファイルの更新
- [x] `config/cable.yml`からRedis設定削除
- [x] `config/initializers/session_store.rb`のRedis設定削除
- [x] `config/initializers/sentry.rb`からredis_logger削除（必要に応じて）

#### 環境変数の削除
- [x] `compose.yaml`から`REDIS_URL`削除
- [x] `compose-dev.yaml`から`REDIS_URL`削除
- [x] `README.md`の環境変数例から`REDIS_URL`削除

### フェーズ4: Docker環境の更新

#### Docker Compose設定更新
- [x] `compose.yaml`からredisサービス削除
- [x] `compose-dev.yaml`からredisサービス削除
- [x] `redis-data`ボリューム削除
- [x] 依存関係の調整（redisに依存していたサービスの更新）

#### ドキュメント更新
- [x] `README.md`のDocker起動コマンド更新
- [x] `CLAUDE.md`の開発用起動コマンド更新
- [ ] `.github/workflows/ci.yml`のCI設定更新

### フェーズ5: テスト・検証

#### 機能テスト
- [x] セッション機能の動作確認
- [x] Action Cableの動作確認（WebSocket通信）
- [x] キャッシュ機能の動作確認
- [x] 既存のRSpecテスト実行
- [x] 統合テスト実行

#### パフォーマンステスト
- [x] キャッシュ性能の比較測定
- [x] Action Cable性能の比較測定
- [x] データベース負荷の確認
- [x] メモリ使用量の確認

### フェーズ6: 本番環境対応

#### 本番環境設定
- [x] 本番環境でのマイグレーション実行計画策定
- [x] セッション移行戦略の決定（ユーザーの一時ログアウト許容性確認）
- [x] ロールバック手順の準備
- [x] 監視・アラート設定の調整

#### デプロイ準備
- [x] ステージング環境での動作確認
- [x] 本番環境でのテスト計画策定
- [x] メンテナンス時間の調整
- [x] 関係者への事前通知

## リスク管理

### 既知のリスク
- [x] セッション移行時の全ユーザー一時ログアウト
- [x] データベース負荷の軽微な増加
- [x] キャッシュ性能の変化（Redis→SSD-backed database）
- [x] Action Cableの性能変化（pub/sub→polling）

### 対策
- [x] 段階的移行の検討（必要に応じて）
- [x] データベースチューニングの実施
- [x] 監視体制の強化
- [x] ロールバック手順の確立

## 完了確認

### 動作確認項目
- [x] Redisプロセスが起動していない状態での完全動作
- [x] 全機能の正常動作確認
- [x] パフォーマンス許容範囲内での動作確認
- [x] CI/CDパイプラインの正常動作

### 清掃作業
- [x] 不要なRedis関連ファイルの削除
- [x] 不要な環境変数の削除
- [x] ドキュメントの最終更新
- [x] チーム内での変更内容共有

## メモ・参考情報

### Rails 8 Solid Cache・Solid Cableの利点
- 外部依存関係の削除
- 単一データベースでの統合管理
- Rails標準機能の活用
- インフラ運用コストの削減
- SSDを活用した大容量・低コストキャッシュ

### パフォーマンス考慮
- Solid Cacheは高速SSDでRedisと同等性能
- Solid Cableはポーリングベースだが実用的な性能
- MySQLでの最適化されたパフォーマンス