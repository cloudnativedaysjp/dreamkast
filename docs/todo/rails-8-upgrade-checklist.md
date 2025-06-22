# Rails 8 アップグレード チェックリスト

## Phase 1: 環境準備 (1-2週間)

### Ruby環境の更新
- [x] Ruby 3.2.0以上への更新確認 - ✅ Ruby 3.3.6 使用中
- [x] 開発環境でのRuby更新 - ✅ 完了（Ruby 3.3.6）
- [x] 本番環境でのRuby更新準備 - ✅ 完了
- [x] CI/CDパイプラインの更新 - ✅ 完了

### 現状の詳細調査
- [x] 非推奨機能の使用状況確認 - ✅ 完了（主要な問題: web_console設定、Rails.application.secrets使用）
- [x] gem互換性の調査 - ✅ 完了（redis-railsが主要な懸念事項）
- [x] カスタム設定の棚卸し - ✅ 完了（load_defaults 6.1→8.0更新が必要）

### Phase 1で発見された問題の修正（Rails更新前に実施）
#### 高優先度
- [x] config.web_console.whitelisted_ips の非推奨設定を削除（development.rb:80） - ✅ 完了
- [x] Rails.application.secrets を credentials または環境変数に置換（json_web_token.rb:11） - ✅ 完了
- [x] config.load_defaults(6.1) を 7.0 に更新（application.rb:16） - ✅ 完了
- [x] new_framework_defaults_7_0.rb の設定を有効化・テスト - ✅ 完了

#### 中優先度
- [x] 非推奨の ActiveSupport::EventedFileUpdateChecker 設定を更新 - ✅ 完了
- [x] カスタムミドルウェア（DreamkastExporter、RescueFromInvalidAuthenticityToken）の互換性確認 - ✅ 完了
- [x] Redis session store の Rails 8 互換性テスト - ✅ 完了

#### 低優先度
- [x] speaker_announcement.rb の scope を lambda→proc 記法に更新 - ✅ 完了
- [x] prometheus-client を最新版(4.2.4)に更新 - ✅ 完了

## Phase 2: 段階的Rails更新 (3-4週間)

### Step 1: Rails 7.0 → 7.1
- [x] Gemfileの更新: `gem 'rails', '~> 7.1.0'`
- [x] `bundle update rails` 実行
- [x] `rails app:update` でconfig更新
- [x] bullet gem を Rails 7.1対応版に更新
- [x] autoload_paths設定をRails 7.1に対応
- [x] ミドルウェアのrequire文を追加
- [x] 残りの問題修正: EnvHelperとautoload関連エラー
- [x] 日本語ロケール設定追加
- [x] モデルテスト95例すべて通過確認
- [x] CSVライブラリの修正
- [x] Prometheusメトリクス重複登録の修正

### Step 2: Rails 7.1 → 7.2
- [x] Gemfileの更新: `gem 'rails', '~> 7.2.0'`
- [x] `bundle update rails` 実行
- [x] `rails app:update` でconfig更新
- [x] テスト実行・修正
- [x] AWS rails gem設定修正
- [x] MiddlewareのRequire追加
- [x] ActiveJob queue adapter設定修正
- [x] Rubocop実行・修正

### Step 3: Rails 7.2 → 8.0
- [ ] Gemfileの更新: `gem 'rails', '~> 8.0.0'`
- [ ] `bundle update rails` 実行
- [ ] `rails app:update` でconfig更新
- [ ] 非推奨警告の解消

## Phase 3: Rails 8新機能の採用検討 (2-3週間)

### Solid Suite の評価
- [ ] 現在の Redis 使用箇所を特定
- [ ] Solid Cable（Action Cableバックエンド）評価
- [ ] Solid Queue（Active Jobバックエンド）評価
- [ ] Solid Cache（Railsキャッシュバックエンド）評価
- [ ] redis-rails から Solid Suite への移行可能性を評価
- [ ] パフォーマンス影響の検討
- [ ] 移行計画の策定

### 認証システムの評価
- [ ] Rails 8内蔵認証機能の検討
- [ ] 現在のAuth0との統合維持確認

### Kamalデプロイメント
- [ ] 現在のデプロイ方式の見直し
- [ ] Kamal導入の検討

## Phase 4: 設定最適化とクリーンアップ (1週間)

### 設定ファイルの更新
- [ ] `config.load_defaults 8.0` に更新
- [ ] `config/initializers/new_framework_defaults_7_0.rb` の設定適用・削除
- [ ] 残存する非推奨設定の最終チェック・削除

### セキュリティ強化
- [ ] Regexp.timeout のデフォルト値確認
- [ ] その他セキュリティ設定の見直し

## 技術的考慮事項

### 破壊的変更への対応
- [ ] データベースマイグレーション動作確認
- [ ] CI/CDでの影響確認
- [ ] Active Record変更への対応
- [ ] enum定義方法の確認
- [ ] 依存gem互換性確認
- [ ] 代替gem検討（必要に応じて）

### パフォーマンス影響
- [ ] データベース最適化確認
- [ ] Solid Suite による外部依存削減効果測定
- [ ] キャッシング効率化確認
- [ ] メモリ使用量の変化測定

## リスク軽減

### 高リスク項目
- [ ] ステージング環境での十分な検証
- [ ] 段階的なロールアウト計画
- [ ] gem互換性問題の事前調査
- [ ] 代替gem の準備

### 中リスク項目
- [ ] 設定変更の段階的適用
- [ ] 包括的なテストスイート実行
- [ ] ロールバック手順の準備
- [ ] Blue-Greenデプロイ検討

## 成功基準

### 機能要件
- [ ] 全既存機能の正常動作確認
- [ ] 全テストスイートの通過
- [ ] API互換性の維持確認

### 非機能要件
- [ ] レスポンス時間の維持または改善確認
- [ ] メモリ使用量の最適化確認
- [ ] セキュリティレベルの向上確認

### 運用要件
- [ ] ダウンタイムなしでの移行完了
- [ ] 監視・ログ機能の継続確認
- [ ] バックアップ・復旧手順の確立

## 最終確認
- [ ] 本番環境でのデプロイ完了
- [ ] 監視アラートの正常動作確認
- [ ] チーム全体への移行完了報告
- [ ] ドキュメントの更新完了