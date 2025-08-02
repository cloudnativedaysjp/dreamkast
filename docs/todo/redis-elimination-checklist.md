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
- [ ] `bin/rails solid_cache:install`実行
- [ ] `config/cache.yml`生成確認
- [ ] `db/cache_schema.rb`生成確認
- [ ] マイグレーション実行
- [ ] `config/environments/production.rb`にキャッシュストア設定追加

#### Solid Cable導入
- [ ] `bin/rails solid_cable:install`実行
- [ ] `config/cable.yml`をsolid_cableアダプターに更新
- [ ] `db/cable_schema.rb`生成確認
- [ ] マイグレーション実行

### フェーズ2: セッションストアの移行

#### ActiveRecord Session Store導入
- [ ] `activerecord-session_store` gem追加
- [ ] `config/initializers/session_store.rb`更新
- [ ] セッションテーブル作成（`bin/rails generate active_record:session_migration`）
- [ ] マイグレーション実行

### フェーズ3: Redis関連の削除

#### Gem依存関係の削除
- [ ] `Gemfile`から`redis`削除
- [ ] `Gemfile`から`redis-session-store`削除
- [ ] `bundle install`実行
- [ ] `Gemfile.lock`更新確認

#### 設定ファイルの更新
- [ ] `config/cable.yml`からRedis設定削除
- [ ] `config/initializers/session_store.rb`のRedis設定削除
- [ ] `config/initializers/sentry.rb`からredis_logger削除（必要に応じて）

#### 環境変数の削除
- [ ] `compose.yaml`から`REDIS_URL`削除
- [ ] `compose-dev.yaml`から`REDIS_URL`削除
- [ ] `README.md`の環境変数例から`REDIS_URL`削除

### フェーズ4: Docker環境の更新

#### Docker Compose設定更新
- [ ] `compose.yaml`からredisサービス削除
- [ ] `compose-dev.yaml`からredisサービス削除
- [ ] `redis-data`ボリューム削除
- [ ] 依存関係の調整（redisに依存していたサービスの更新）

#### ドキュメント更新
- [ ] `README.md`のDocker起動コマンド更新
- [ ] `CLAUDE.md`の開発用起動コマンド更新
- [ ] `.github/workflows/ci.yml`のCI設定更新

### フェーズ5: テスト・検証

#### 機能テスト
- [ ] セッション機能の動作確認
- [ ] Action Cableの動作確認（WebSocket通信）
- [ ] キャッシュ機能の動作確認
- [ ] 既存のRSpecテスト実行
- [ ] 統合テスト実行

#### パフォーマンステスト
- [ ] キャッシュ性能の比較測定
- [ ] Action Cable性能の比較測定
- [ ] データベース負荷の確認
- [ ] メモリ使用量の確認

### フェーズ6: 本番環境対応

#### 本番環境設定
- [ ] 本番環境でのマイグレーション実行計画策定
- [ ] セッション移行戦略の決定（ユーザーの一時ログアウト許容性確認）
- [ ] ロールバック手順の準備
- [ ] 監視・アラート設定の調整

#### デプロイ準備
- [ ] ステージング環境での動作確認
- [ ] 本番環境でのテスト計画策定
- [ ] メンテナンス時間の調整
- [ ] 関係者への事前通知

## リスク管理

### 既知のリスク
- [ ] セッション移行時の全ユーザー一時ログアウト
- [ ] データベース負荷の軽微な増加
- [ ] キャッシュ性能の変化（Redis→SSD-backed database）
- [ ] Action Cableの性能変化（pub/sub→polling）

### 対策
- [ ] 段階的移行の検討（必要に応じて）
- [ ] データベースチューニングの実施
- [ ] 監視体制の強化
- [ ] ロールバック手順の確立

## 完了確認

### 動作確認項目
- [ ] Redisプロセスが起動していない状態での完全動作
- [ ] 全機能の正常動作確認
- [ ] パフォーマンス許容範囲内での動作確認
- [ ] CI/CDパイプラインの正常動作

### 清掃作業
- [ ] 不要なRedis関連ファイルの削除
- [ ] 不要な環境変数の削除
- [ ] ドキュメントの最終更新
- [ ] チーム内での変更内容共有

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