# ADR 002: Session Attribute Management Design

## Status
**Proposed** - 2025-01-10

## Context

### Current Situation
Dreamkastプラットフォームでは、Talkモデルでセッション管理を行っており、現在は以下の方式でセッションタイプを判定している：

- **STI (Single Table Inheritance)**: `type`カラムで`Session`, `KeynoteSession`, `SponsorSession`, `Intermission`を区別
- **sponsor_id**: スポンサーセッションの判定用
- **abstract='intermission'**: 休憩時間の判定用

### Problem Statement
新たな要件として「**スポンサーセッションかつキーノート**」という複合属性を持つセッションが必要になった。しかし、現在のSTI構造では1つのセッションに複数の属性を持たせることができない。

### Requirements
1. スポンサーセッション + キーノートの組み合わせを表現可能
2. 従来のセッションタイプ（Session, Keynote, Sponsor, Intermission）を維持
3. Admin画面での柔軟な設定機能
4. 将来的な新しい属性追加への対応
5. 既存データの安全な移行

## Options Considered

### Option 1: STI継続 + 新クラス追加
現在のSTI構造を維持し、`SponsorKeynoteSession`クラスを追加

**Pros:**
- 既存コードへの影響最小
- 型安全性の維持

**Cons:**
- 複合パターンごとにクラス増加
- 拡張性の欠如
- Admin UIの複雑化

### Option 2: フラグベース管理
STIを廃止し、booleanカラム（`is_keynote`, `is_intermission`など）で管理

**Pros:**
- 複合属性の自然な表現
- Admin UIがシンプル

**Cons:**
- セッション固有の属性管理が困難
- バリデーション複雑化
- 正規化の観点で問題

### Option 3: 中間テーブル方式
正規化されたセッション属性テーブル + 中間テーブルでの多対多関係

**Pros:**
- 完全に正規化された設計
- 柔軟な属性組み合わせ
- 新属性追加が容易
- 属性固有設定のサポート

**Cons:**
- 実装複雑度の増加
- パフォーマンスへの若干の影響

### Option 4: 個別テーブル方式
属性ごとに専用テーブル（`keynote_sessions`, `sponsor_sessions`など）

**Pros:**
- 各属性の型安全性
- 属性固有制約の強制

**Cons:**
- 複合パターンで極めて複雑
- テーブル数の爆発的増加
- 保守性の低下

## Decision

**Option 3: 中間テーブル方式**を採用する。

### Key Design Elements

```sql
-- セッション属性マスタ
CREATE TABLE session_attributes (
  id BIGINT PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  is_exclusive BOOLEAN DEFAULT FALSE,
  config_schema JSON,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Talk-属性中間テーブル
CREATE TABLE talk_session_attributes (
  id BIGINT PRIMARY KEY,
  talk_id BIGINT NOT NULL,
  session_attribute_id BIGINT NOT NULL,
  config_data JSON,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(talk_id, session_attribute_id)
);
```

### 属性例
```json
[
  {"name": "keynote", "display_name": "キーノート", "is_exclusive": false},
  {"name": "sponsor", "display_name": "スポンサー", "is_exclusive": false},
  {"name": "intermission", "display_name": "休憩", "is_exclusive": true},
  {"name": "lightning", "display_name": "ライトニングトーク", "is_exclusive": false},
  {"name": "workshop", "display_name": "ワークショップ", "is_exclusive": false}
]
```

## Rationale

1. **要件への適応性**: スポンサーキーノート等の複合要件に自然対応
2. **拡張性**: 新属性（ワークショップ、パネルディスカッションなど）の追加が容易
3. **正規化**: データベース設計のベストプラクティスに準拠
4. **保守性**: 属性追加でのコード変更が最小限
5. **管理UI**: チェックボックベースの直感的な操作

## Consequences

### Positive
- 複合セッション属性の柔軟な表現
- 新属性追加時の影響範囲限定
- Admin UIのシンプル化
- データ整合性の向上
- 将来的な要件変更への対応力

### Negative
- 初期実装コストの増加
- JOINクエリによる若干のパフォーマンス影響
- 既存コードのリファクタリング必要

### Risks and Mitigations
- **リスク**: 複雑なバリデーションロジック
  - **緩和策**: JSONスキーマバリデーションの活用
- **リスク**: 既存データの移行失敗
  - **緩和策**: 段階的移行とロールバック計画

## Implementation Plan

### Phase 1: 基盤構築（2週間）
- 新テーブル作成
- 基本的なモデル実装
- 既存データの移行スクリプト

### Phase 2: 機能実装（3週間）
- Talk モデルの拡張
- Admin UI の更新
- バリデーション実装

### Phase 3: 統合・テスト（2週間）
- 既存機能との統合テスト
- パフォーマンステスト
- ドキュメント更新

### Phase 4: 移行・クリーンアップ（1週間）
- 本番データ移行
- 古いコードのクリーンアップ
- モニタリング

## References

- [Database Design and Normalization](../database-design/)
- [Session Management Implementation Details](../session-management/)
- [Current Talk Model Analysis](../session-management/current-analysis.md)

---

**Approved by**: [To be filled]  
**Review Date**: [To be scheduled]  
**Next Review**: [6 months after implementation]