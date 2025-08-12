# Design Approach Comparison

## Overview
このドキュメントでは、セッション属性管理の4つの設計アプローチを詳細に比較します。

## Comparison Matrix

| 項目 | STI継続 | フラグ方式 | 中間テーブル | 個別テーブル |
|------|---------|------------|-------------|-------------|
| **複合属性対応** | ❌ | ✅ | ✅ | ⚠️ |
| **型安全性** | ✅ | ❌ | ⚠️ | ✅ |
| **実装複雑度** | ✅ | ✅ | ⚠️ | ❌ |
| **拡張性** | ❌ | ⚠️ | ✅ | ❌ |
| **パフォーマンス** | ✅ | ✅ | ⚠️ | ❌ |
| **正規化度** | ❌ | ❌ | ✅ | ✅ |

## Detailed Analysis

### Option 1: STI継続 + 新クラス追加

#### Schema Design
```sql
-- 変更なし
CREATE TABLE talks (
  type VARCHAR(255) NOT NULL,  -- 既存
  -- 新しいtype値: 'SponsorKeynoteSession'
);

-- 新しいSTIクラス
CREATE TABLE talk_types (
  id VARCHAR(255) PRIMARY KEY,
  -- 'SponsorKeynoteSession' を追加
);
```

#### Ruby Implementation
```ruby
# 新しいSTIクラス
class SponsorKeynoteSession < Talk
  belongs_to :sponsor
  
  def keynote?
    true
  end
  
  def sponsor_session?
    true
  end
end

# Typeクラス更新
class Talk::Type < ApplicationRecord
  KLASSES = [
    Session, 
    KeynoteSession, 
    SponsorSession, 
    SponsorKeynoteSession,  # 追加
    Intermission
  ].freeze
end
```

#### Admin UI
```erb
<!-- 複雑な選択肢 -->
<%= select_tag "talk[type]", options_for_select([
  ['通常セッション', 'Session'],
  ['キーノート', 'KeynoteSession'],
  ['スポンサーセッション', 'SponsorSession'],
  ['スポンサーキーノート', 'SponsorKeynoteSession'], <!-- 新規 -->
  ['休憩', 'Intermission']
]) %>
```

#### Pros & Cons
**Pros:**
- 既存コードへの影響最小
- 型安全性の維持
- パフォーマンス影響なし

**Cons:**
- 組み合わせ爆発：N個の属性で2^N個のクラス必要
- 新しい属性追加でコード変更必要
- 複合判定ロジックの複雑化

### Option 2: フラグベース管理

#### Schema Design
```sql
ALTER TABLE talks DROP COLUMN type;  -- STI廃止
ALTER TABLE talks ADD COLUMN is_keynote BOOLEAN DEFAULT FALSE;
ALTER TABLE talks ADD COLUMN is_intermission BOOLEAN DEFAULT FALSE;
-- sponsor_idは既存維持
```

#### Ruby Implementation
```ruby
class Talk < ApplicationRecord
  # バリデーション
  validates :is_intermission, 
    exclusion: { in: [true], 
    if: -> { is_keynote? || sponsor_id.present? } }
  
  def keynote?
    is_keynote
  end
  
  def sponsor_session?
    sponsor_id.present?
  end
  
  def sponsor_keynote?
    is_keynote && sponsor_id.present?
  end
  
  def intermission?
    is_intermission
  end
  
  # スコープ
  scope :keynotes, -> { where(is_keynote: true) }
  scope :sponsor_keynotes, -> { 
    where(is_keynote: true).where.not(sponsor_id: nil) 
  }
end
```

#### Admin UI
```erb
<%= check_box_tag "is_keynote", 1, talk.is_keynote %>
<label>キーノート</label>

<%= check_box_tag "is_intermission", 1, talk.is_intermission %>
<label>休憩</label>

<!-- sponsor_idは既存のsponsor選択UIで管理 -->
```

#### Pros & Cons
**Pros:**
- 複合属性の自然な表現
- Admin UIがシンプル
- パフォーマンス良好

**Cons:**
- 属性固有設定の管理困難
- バリデーション複雑化
- 正規化の観点で問題

### Option 3: 中間テーブル方式（推奨）

#### Schema Design
```sql
-- 新しいテーブル
CREATE TABLE session_attributes (
  id BIGINT PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  is_exclusive BOOLEAN DEFAULT FALSE,
  config_schema JSON,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE talk_session_attributes (
  id BIGINT PRIMARY KEY,
  talk_id BIGINT NOT NULL,
  session_attribute_id BIGINT NOT NULL,
  config_data JSON,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(talk_id, session_attribute_id),
  FOREIGN KEY (talk_id) REFERENCES talks(id),
  FOREIGN KEY (session_attribute_id) REFERENCES session_attributes(id)
);
```

#### Ruby Implementation
```ruby
class SessionAttribute < ApplicationRecord
  has_many :talk_session_attributes
  has_many :talks, through: :talk_session_attributes
  
  validates :name, presence: true, uniqueness: true
  validates :config_schema, json: true
end

class TalkSessionAttribute < ApplicationRecord
  belongs_to :talk
  belongs_to :session_attribute
  
  validate :config_data_matches_schema
  validate :exclusive_attribute_check
  
  private
  
  def config_data_matches_schema
    # JSONスキーマバリデーション
  end
  
  def exclusive_attribute_check
    return unless session_attribute.is_exclusive
    
    other_attributes = talk.session_attributes.where.not(id: session_attribute.id)
    if other_attributes.exists?
      errors.add(:session_attribute, 'cannot coexist with other attributes')
    end
  end
end

class Talk < ApplicationRecord
  has_many :talk_session_attributes, dependent: :destroy
  has_many :session_attributes, through: :talk_session_attributes
  
  def keynote?
    session_attributes.exists?(name: 'keynote')
  end
  
  def sponsor_session?
    session_attributes.exists?(name: 'sponsor')
  end
  
  def sponsor_keynote?
    keynote? && sponsor_session?
  end
  
  def intermission?
    session_attributes.exists?(name: 'intermission')
  end
  
  # スコープ
  scope :keynotes, -> { 
    joins(:session_attributes).where(session_attributes: { name: 'keynote' })
  }
  
  scope :sponsor_keynotes, -> {
    joins(:session_attributes)
      .where(session_attributes: { name: ['keynote', 'sponsor'] })
      .group('talks.id')
      .having('COUNT(session_attributes.id) = 2')
  }
end
```

#### Query Examples
```ruby
# 単一属性検索
Talk.keynotes

# 複合属性検索
Talk.sponsor_keynotes

# 複雑な検索
Talk.joins(:session_attributes)
    .where(session_attributes: { name: ['keynote', 'workshop'] })
    .having('COUNT(DISTINCT session_attributes.name) >= 1')
```

#### Admin UI
```erb
<% SessionAttribute.all.each do |attr| %>
  <div class="form-check">
    <%= check_box_tag "session_attributes[]", attr.id,
                      talk.session_attributes.include?(attr),
                      id: "attr_#{attr.id}",
                      class: "form-check-input",
                      data: { exclusive: attr.is_exclusive } %>
    <%= label_tag "attr_#{attr.id}", attr.display_name, 
                  class: "form-check-label" %>
  </div>
<% end %>

<script>
// JavaScript for exclusive control
document.addEventListener('DOMContentLoaded', function() {
  const exclusiveCheckboxes = document.querySelectorAll('[data-exclusive="true"]');
  const regularCheckboxes = document.querySelectorAll('[data-exclusive="false"]');
  
  exclusiveCheckboxes.forEach(exclusive => {
    exclusive.addEventListener('change', function() {
      if (this.checked) {
        regularCheckboxes.forEach(regular => regular.checked = false);
      }
    });
  });
  
  regularCheckboxes.forEach(regular => {
    regular.addEventListener('change', function() {
      if (this.checked) {
        exclusiveCheckboxes.forEach(exclusive => exclusive.checked = false);
      }
    });
  });
});
</script>
```

#### Pros & Cons
**Pros:**
- 完全正規化された設計
- 柔軟な属性組み合わせ
- 新属性追加が容易
- 属性固有設定サポート

**Cons:**
- JOINクエリのコスト
- 実装の複雑さ
- JSONバリデーションの複雑さ

### Option 4: 個別テーブル方式

#### Schema Design
```sql
CREATE TABLE keynote_sessions (
  id BIGINT PRIMARY KEY,
  talk_id BIGINT NOT NULL UNIQUE,
  keynote_type ENUM('opening', 'closing', 'main'),
  speaker_fee DECIMAL(10,2),
  created_at TIMESTAMP,
  FOREIGN KEY (talk_id) REFERENCES talks(id)
);

CREATE TABLE sponsor_sessions (
  id BIGINT PRIMARY KEY,
  talk_id BIGINT NOT NULL UNIQUE,
  sponsor_id BIGINT NOT NULL,
  sponsorship_level ENUM('platinum', 'gold', 'silver'),
  contract_amount DECIMAL(10,2),
  created_at TIMESTAMP,
  FOREIGN KEY (talk_id) REFERENCES talks(id)
);

-- 複合パターン用（複雑）
CREATE TABLE sponsor_keynote_sessions (
  id BIGINT PRIMARY KEY,
  talk_id BIGINT NOT NULL UNIQUE,
  keynote_session_id BIGINT,
  sponsor_session_id BIGINT,
  created_at TIMESTAMP,
  FOREIGN KEY (keynote_session_id) REFERENCES keynote_sessions(id),
  FOREIGN KEY (sponsor_session_id) REFERENCES sponsor_sessions(id)
);
```

#### Ruby Implementation
```ruby
class KeynoteSession < ApplicationRecord
  belongs_to :talk
  validates :keynote_type, inclusion: { in: %w[opening closing main] }
end

class SponsorSession < ApplicationRecord
  belongs_to :talk
  belongs_to :sponsor
  validates :sponsorship_level, 
    inclusion: { in: %w[platinum gold silver] }
end

# 複合パターンは非常に複雑
class SponsorKeynoteSession < ApplicationRecord
  belongs_to :talk
  belongs_to :keynote_session, optional: true
  belongs_to :sponsor_session, optional: true
  
  validate :must_have_both_attributes
end

class Talk < ApplicationRecord
  has_one :keynote_session
  has_one :sponsor_session
  has_one :sponsor_keynote_session
  
  def keynote?
    keynote_session.present? || sponsor_keynote_session.present?
  end
  
  def sponsor_session?
    sponsor_session.present? || sponsor_keynote_session.present?
  end
  
  # 複雑な判定ロジック...
end
```

#### Query Performance
```ruby
# 複雑なクエリが必要
Talk.left_joins(:keynote_session, :sponsor_keynote_session)
    .where('keynote_sessions.id IS NOT NULL OR sponsor_keynote_sessions.id IS NOT NULL')
```

#### Pros & Cons
**Pros:**
- 強い型安全性
- 属性固有制約の強制
- パフォーマンス（単一テーブルアクセス）

**Cons:**
- 複合パターンで極めて複雑
- テーブル数の爆発的増加
- Admin UIの複雑化
- 保守性の著しい低下

## Performance Analysis

### Query Complexity Comparison

#### 中間テーブル方式
```sql
-- キーノートセッション検索
SELECT t.* FROM talks t
JOIN talk_session_attributes tsa ON t.id = tsa.talk_id
JOIN session_attributes sa ON tsa.session_attribute_id = sa.id
WHERE sa.name = 'keynote';

-- スポンサーキーノート検索
SELECT t.* FROM talks t
WHERE t.id IN (
  SELECT tsa.talk_id FROM talk_session_attributes tsa
  JOIN session_attributes sa ON tsa.session_attribute_id = sa.id
  WHERE sa.name IN ('keynote', 'sponsor')
  GROUP BY tsa.talk_id
  HAVING COUNT(DISTINCT sa.name) = 2
);
```

#### 個別テーブル方式
```sql
-- 複雑な結合が必要
SELECT t.* FROM talks t
LEFT JOIN keynote_sessions k ON t.id = k.talk_id
LEFT JOIN sponsor_sessions s ON t.id = s.talk_id
LEFT JOIN sponsor_keynote_sessions sk ON t.id = sk.talk_id
WHERE k.id IS NOT NULL OR sk.id IS NOT NULL;
```

### Index Strategy

#### 中間テーブル方式
```sql
CREATE INDEX idx_talk_session_attrs_talk_id ON talk_session_attributes(talk_id);
CREATE INDEX idx_talk_session_attrs_attr_id ON talk_session_attributes(session_attribute_id);
CREATE INDEX idx_session_attrs_name ON session_attributes(name);
CREATE UNIQUE INDEX idx_talk_session_unique ON talk_session_attributes(talk_id, session_attribute_id);
```

## Recommendation

**中間テーブル方式（Option 3）**を強く推奨します。

### 理由

1. **要件適合性**: スポンサーキーノートなど複合要件に完全対応
2. **拡張性**: 将来の新属性追加が容易
3. **正規化**: データベース設計のベストプラクティス準拠
4. **保守性**: コード変更の影響範囲が限定的
5. **バランス**: 実装複雑度とメリットのバランスが最適

### 次点の選択肢

フラグベース方式（Option 2）は、属性固有設定が不要な場合の簡易な代替案として考慮可能。

### 避けるべき選択肢

- **STI継続**: 要件に対応不可
- **個別テーブル**: 実装・保守コストが過大