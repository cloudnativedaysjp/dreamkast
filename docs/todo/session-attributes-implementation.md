# Session Attributes Implementation TODO

## Overview
talk_session_attributes方式によるセッション属性管理システムの実装タスクリスト（シンプル版）

## Phase 1: Foundation Setup (2 weeks)

### 1.1 Database Schema Creation
- [ ] session_attributesテーブル作成マイグレーション
- [ ] talk_session_attributesテーブル作成マイグレーション  
- [ ] 必要なインデックス追加
- [ ] 外部キー制約設定

### 1.2 Master Data Setup
- [ ] session_attributesマスタデータ投入マイグレーション
- [ ] keynote属性の追加
- [ ] sponsor属性の追加
- [ ] intermission属性の追加（is_exclusive: true）

### 1.3 Model Implementation
- [ ] SessionAttributeモデル作成
  - [ ] 基本バリデーション実装
  - [ ] クラスメソッド実装
  - [ ] インスタンスメソッド実装
- [ ] TalkSessionAttributeモデル作成
  - [ ] 基本バリデーション実装
  - [ ] 排他属性チェックバリデーション
  - [ ] コールバック実装
- [ ] Talkモデル拡張
  - [ ] has_many関連追加
  - [ ] 判定メソッド実装（keynote?, sponsor_session?, intermission?）
  - [ ] 属性管理メソッド実装
  - [ ] 新しいスコープ実装

### 1.4 Data Migration
- [ ] 既存データ移行スクリプト作成
- [ ] KeynoteSession -> keynote attribute変換
- [ ] SponsorSession -> sponsor attribute変換  
- [ ] Intermission -> intermission attribute変換
- [ ] sponsor_id -> sponsor attribute変換
- [ ] abstract='intermission' -> intermission attribute変換
- [ ] マイグレーション実行
- [ ] データ整合性検証

### 1.5 Backward Compatibility
- [ ] LegacySessionSupportモジュール作成
- [ ] 既存メソッドのエイリアス設定
- [ ] 拡張されたメソッドの互換性確保
- [ ] 既存スコープとの互換性確保

## Phase 2: Feature Implementation (3 weeks)

### 2.1 Validation & Business Logic
- [ ] 排他属性制約バリデーション
- [ ] ビジネスルール制約バリデーション
- [ ] エラーメッセージ日本語化

### 2.2 Service Layer
- [ ] SessionAttributeService作成
- [ ] 属性一括割り当てロジック
- [ ] バリデーション処理
- [ ] エラーハンドリング
- [ ] トランザクション制御

### 2.3 Admin Controller Updates
- [ ] Admin::TalksController修正
- [ ] update_talksアクション実装
- [ ] セッション属性更新ロジック
- [ ] Strong Parameters設定
- [ ] エラーハンドリング実装

### 2.4 Admin View Updates
- [ ] talks/index.html.erb修正
- [ ] セッション属性カラム追加
- [ ] チェックボックス形式の属性選択UI（keynote, sponsor, intermission）
- [ ] JavaScript制御実装（排他制御）
- [ ] CSS/JavaScript assets追加

### 2.5 Helper Methods
- [ ] Admin::SessionAttributesHelper作成
- [ ] session_attribute_checkboxesメソッド
- [ ] session_attribute_checkboxメソッド

### 2.6 JavaScript Implementation
- [ ] SessionAttributesManagerクラス作成
- [ ] イベントリスナー実装
- [ ] 排他制御ロジック（intermissionが選択されたら他を外す）
- [ ] 一括操作機能

## Phase 3: Integration & Testing (2 weeks)

### 3.1 Model Tests
- [ ] SessionAttributeモデルspec作成
  - [ ] バリデーションテスト
  - [ ] メソッドテスト
- [ ] TalkSessionAttributeモデルspec作成
  - [ ] バリデーションテスト
  - [ ] 排他制御テスト
- [ ] Talkモデル拡張spec作成
  - [ ] 新しいメソッドのテスト
  - [ ] 後方互換性テスト
  - [ ] スコープテスト

### 3.2 Controller Tests
- [ ] Admin::TalksControllerspec修正
- [ ] update_talksアクションテスト
- [ ] Strong Parametersテスト
- [ ] エラーケーステスト

### 3.3 Feature Tests
- [ ] Admin UI統合テスト作成
- [ ] セッション属性設定フローテスト
- [ ] 排他制御UIテスト（intermission選択時の動作確認）

### 3.4 Factory & Test Data
- [ ] SessionAttributeファクトリー作成
- [ ] TalkSessionAttributeファクトリー作成
- [ ] テストデータ用trait追加
- [ ] Shared examplesの実装

### 3.5 Integration Testing
- [ ] 既存機能との統合テスト
- [ ] パフォーマンステスト
- [ ] データ整合性テスト

## Phase 4: Migration & Cleanup (1 week)

### 4.1 Production Readiness
- [ ] マイグレーション検証スクリプト作成
- [ ] データ整合性チェックrakeタスク
- [ ] レポート生成rakeタスク
- [ ] パフォーマンス監視設定

### 4.2 Deployment Preparation
- [ ] 本番環境用migration確認
- [ ] Rollback手順文書化
- [ ] 緊急時対応手順作成
- [ ] 監視・アラート設定

### 4.3 Documentation Updates
- [ ] README更新
- [ ] API仕様書更新
- [ ] 管理者向け操作マニュアル作成
- [ ] 開発者向けドキュメント更新

### 4.4 Monitoring & Validation
- [ ] 本番デプロイ実行
- [ ] データ移行検証
- [ ] パフォーマンス監視
- [ ] エラー監視設定

## Phase 5: Future Enhancements (Optional)

### 5.1 Legacy Code Cleanup
- [ ] 古いSTIコードの段階的削除
- [ ] 不要なメソッド削除
- [ ] テストケース整理
- [ ] ドキュメント整理

## Success Criteria

### Functional Requirements
- [ ] 既存のすべてのセッションタイプが正常に動作
- [ ] 新しい複合タイプ（sponsor + keynote）が動作  
- [ ] Admin UIが直感的で使いやすい
- [ ] データの整合性が保たれている
- [ ] エラー処理が適切に実装されている

### Non-Functional Requirements  
- [ ] パフォーマンスがベースラインの10%以内
- [ ] Admin画面のロード時間が2秒以内
- [ ] データベースサイズ増加が5%以内
- [ ] テストカバレッジが95%以上
- [ ] ゼロダウンタイムでのデプロイ

### Quality Requirements
- [ ] コードレビュー完了
- [ ] セキュリティ検証完了
- [ ] ドキュメント整備完了
- [ ] 本番環境での動作確認完了

## Risk Management

### High Risk Items
- [ ] データマイグレーション時の整合性確保
- [ ] 既存機能への影響範囲の特定と対策
- [ ] パフォーマンス劣化の防止

### Medium Risk Items  
- [ ] UI/UXの操作性確保
- [ ] ブラウザ互換性確保
- [ ] 大量データでの動作確認

### Low Risk Items
- [ ] 新機能の追加学習コスト
- [ ] 既存テストケースの修正作業
- [ ] ドキュメントメンテナンス作業

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|-----------------|
| Phase 1 | 1 week | DB設計、モデル実装、データ移行 |
| Phase 2 | 1 week | UI実装、機能実装 |
| Phase 3 | 1 week | テスト、統合確認 |
| Phase 4 | 3 days | 本番デプロイ、監視 |

**Total: 3-4 weeks**（シンプル化により大幅短縮）

## Notes
- 各フェーズ開始前に前フェーズの成果物レビューを実施
- 週次で進捗確認とリスク評価を実施
- 問題発生時は即座にエスカレーション
- ドキュメントは実装と並行して更新