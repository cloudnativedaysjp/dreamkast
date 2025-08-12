# Session Management Documentation

このディレクトリは、Dreamkastにおけるセッション属性管理システムの設計と実装に関するドキュメントを含んでいます。

## Overview

Dreamkastでは、カンファレンスのセッション（Talk）に対して複数の属性を柔軟に設定できるシステムを採用しています。従来のSingle Table Inheritance (STI)ベースから、正規化された中間テーブルベースの設計に移行しました。

## Key Features

- **複合属性**: スポンサーセッション + キーノートなど、複数属性の組み合わせに対応
- **拡張性**: 新しいセッション属性の追加が容易
- **型安全性**: JSONスキーマによる属性固有設定のバリデーション
- **直感的UI**: Admin画面でのチェックボックスベース管理

## Architecture

```
talks
├── talk_session_attributes (中間テーブル)
│   ├── config_data: 属性固有の設定
│   └── session_attribute_id
└── session_attributes (マスタテーブル)
    ├── name: keynote, sponsor, intermission, etc.
    ├── config_schema: 属性の設定スキーマ定義
    └── is_exclusive: 他属性との排他制御
```

## Session Attribute Types

| 属性名 | 表示名 | 排他的 | 説明 |
|-------|--------|--------|------|
| keynote | キーノート | No | メインの基調講演 |
| sponsor | スポンサー | No | スポンサー企業によるセッション |
| intermission | 休憩 | Yes | 休憩時間（他属性と排他的） |
| lightning | ライトニングトーク | No | 短時間プレゼンテーション |
| workshop | ワークショップ | No | ハンズオン形式のセッション |

## Document Structure

- **[Current Analysis](./current-analysis.md)** - 既存実装の詳細調査結果
- **[Design Comparison](./design-comparison.md)** - 設計手法の比較検討
- **[Implementation Plan](./implementation-plan.md)** - 実装手順とマイグレーション計画
- **[API Specifications](./api-specs.md)** - 新しいモデル・API仕様

## Quick Start

### 1. セッション属性の確認
```ruby
# 利用可能な属性一覧
SessionAttribute.all.pluck(:name, :display_name)

# 特定のセッションの属性
talk = Talk.find(123)
talk.session_attributes.pluck(:name)
```

### 2. セッション属性の設定
```ruby
# キーノートとして設定
keynote_attr = SessionAttribute.find_by(name: 'keynote')
talk.talk_session_attributes.create!(session_attribute: keynote_attr)

# 複数属性の設定（スポンサーキーノート）
sponsor_attr = SessionAttribute.find_by(name: 'sponsor')
talk.session_attributes = [keynote_attr, sponsor_attr]
```

### 3. 判定メソッド
```ruby
talk.keynote?           # => true
talk.sponsor_session?   # => true
talk.sponsor_keynote?   # => true
talk.intermission?      # => false
```

## Migration from Legacy System

既存のSTIベースシステムからの移行は段階的に実施されます：

1. **Phase 1**: 新テーブル作成・既存データ移行
2. **Phase 2**: 新しいモデル・UI実装
3. **Phase 3**: 既存コードの段階的置き換え
4. **Phase 4**: 旧システムのクリーンアップ

詳細は[Implementation Plan](./implementation-plan.md)を参照してください。

## Related Documentation

- [ADR 002: Session Attribute Management Design](../adr/002-session-attribute-management-design.md)
- [Database Design](../database-design/)

## Contributing

セッション管理機能への変更を行う際は、以下のドキュメントを更新してください：

1. 新しい属性追加: [API Specifications](./api-specs.md)を更新
2. 設計変更: 対応するADRを作成または更新
3. 実装変更: [Implementation Plan](./implementation-plan.md)を更新

## Support

質問や問題がある場合は、開発チームまでお問い合わせください。