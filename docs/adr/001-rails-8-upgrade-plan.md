# ADR-001: Rails 8 アップグレード計画

## ステータス
提案中

## 作成日
2025-06-21

## 背景
DreamkastアプリケーションはRails 7.0.5で構築されており、最新のRails 8.0への移行を検討している。Rails 8では多くの新機能と改善が導入されており、パフォーマンスの向上、セキュリティの強化、外部依存関係の削減などのメリットがある。

### 現在の状況
- Rails バージョン: 7.0.5
- Ruby バージョン: 2.6.10（現在のシステム）、プロジェクトでは3.3.6を使用
- Action Cable: Redis を使用
- Active Job: 設定を確認済み
- 多数の gem 依存関係

## 決定事項
DreamkastアプリケーションをRails 8.0に段階的にアップグレードする。

## 移行計画

### Phase 1: 環境準備 (1-2週間)
1. **Ruby環境の更新**
   - Ruby 3.2.0以上への更新（Rails 8.0の要件）
   - 開発環境、本番環境の両方で対応
   - CI/CDパイプラインの更新

2. **現状の詳細調査**
   - 非推奨機能の使用状況確認
   - gem互換性の調査
   - カスタム設定の棚卸し

### Phase 2: 段階的Rails更新 (3-4週間)
#### Step 1: Rails 7.0 → 7.1
1. Gemfileの更新: `gem 'rails', '~> 7.1.0'`
2. `bundle update rails`
3. `rails app:update` でconfig更新
4. テスト実行・修正

#### Step 2: Rails 7.1 → 7.2
1. Gemfileの更新: `gem 'rails', '~> 7.2.0'`
2. `bundle update rails`
3. `rails app:update` でconfig更新
4. テスト実行・修正

#### Step 3: Rails 7.2 → 8.0
1. Gemfileの更新: `gem 'rails', '~> 8.0.0'`
2. `bundle update rails`
3. `rails app:update` でconfig更新
4. 非推奨警告の解消

### Phase 3: Rails 8新機能の採用検討 (2-3週間)
1. **Solid Suite の評価**
   - Solid Cable（Action Cableバックエンド）
   - Solid Queue（Active Jobバックエンド）
   - Solid Cache（Railsキャッシュバックエンド）
   - Redis依存の削減可能性を検討

2. **認証システムの評価**
   - Rails 8内蔵認証機能の検討
   - 現在のAuth0との統合維持

3. **Kamalデプロイメント**
   - 現在のデプロイ方式の見直し
   - Kamal導入の検討

### Phase 4: 設定最適化とクリーンアップ (1週間)
1. **設定ファイルの更新**
   - `config.load_defaults 8.0` に更新
   - `config/initializers/new_framework_defaults_7_0.rb` の設定適用・削除
   - 非推奨設定の削除

2. **セキュリティ強化**
   - Regexp.timeout のデフォルト値確認
   - その他セキュリティ設定の見直し

## 技術的考慮事項

### 破壊的変更への対応
1. **データベースマイグレーション**
   - Rails 8.0では `rails db:migrate` の動作が変更
   - CI/CDでの影響を確認

2. **Active Record変更**
   - 非推奨機能の削除への対応
   - enum定義方法の確認

3. **依存gem互換性**
   - 各gemのRails 8対応状況確認
   - 必要に応じて代替gem検討

### パフォーマンス影響
1. **正の影響**
   - データベース最適化
   - Solid Suite による外部依存削減
   - より効率的なキャッシング

2. **潜在的リスク**
   - 初期設定時のパフォーマンス影響
   - メモリ使用量の変化

## リスクと軽減策

### 高リスク
1. **Ruby更新に伴うシステム影響**
   - 軽減策: ステージング環境での十分な検証
   - 軽減策: 段階的なロールアウト

2. **gem互換性問題**
   - 軽減策: 事前の互換性調査
   - 軽減策: 代替gem の準備

### 中リスク
1. **設定変更による機能影響**
   - 軽減策: 設定変更の段階的適用
   - 軽減策: 包括的なテストスイート実行

2. **デプロイメント問題**
   - 軽減策: ロールバック手順の準備
   - 軽減策: Blue-Greenデプロイ検討

## 成功基準
1. **機能要件**
   - 全既存機能の正常動作
   - 全テストスイートの通過
   - API互換性の維持

2. **非機能要件**
   - レスポンス時間の維持または改善
   - メモリ使用量の最適化
   - セキュリティレベルの向上

3. **運用要件**
   - ダウンタイムなしでの移行完了
   - 監視・ログ機能の継続
   - バックアップ・復旧手順の確立

## タイムライン
- **Phase 1**: 1-2週間（環境準備）
- **Phase 2**: 3-4週間（段階的Rails更新）
- **Phase 3**: 2-3週間（新機能評価・採用）
- **Phase 4**: 1週間（最適化・クリーンアップ）

**総期間**: 7-10週間

## 実装チーム
- リードエンジニア: 1名
- バックエンドエンジニア: 2名
- インフラエンジニア: 1名
- QAエンジニア: 1名

## 参考資料
- [Rails 8.0 Release Notes](https://guides.rubyonrails.org/8_0_release_notes.html)
- [Upgrading Ruby on Rails Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails 7 to 8 Upgrade Guide](https://www.fastruby.io/blog/upgrade-rails-7-2-to-8-0.html)

## 備考
このアップグレードは、長期的なアプリケーションの保守性と性能向上のために重要である。段階的なアプローチにより、リスクを最小化しながら確実に移行を進める。