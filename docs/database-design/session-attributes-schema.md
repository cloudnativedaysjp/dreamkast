# Session Attributes Database Schema

## Overview
セッション属性管理システムの正規化されたデータベーススキーマ設計を詳述します。

## Schema Design Principles

### 1. 正規化レベル
**第3正規形（3NF）**を満たす設計を採用：
- 第1正規形：原子値の保証
- 第2正形：完全関数従属の確保  
- 第3正規形：推移的関数従属の排除

### 2. 設計目標
- **柔軟性**: 複数属性の組み合わせサポート
- **拡張性**: 新属性追加の容易さ
- **整合性**: 制約による整合性保証
- **パフォーマンス**: 適切なインデックス戦略

## Core Tables

### session_attributes (セッション属性マスタ)

```sql
CREATE TABLE session_attributes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  description TEXT,
  is_exclusive BOOLEAN NOT NULL DEFAULT FALSE,
  config_schema JSON,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE KEY uk_session_attributes_name (name),
  
  -- Indexes
  INDEX idx_session_attributes_name (name),
  INDEX idx_session_attributes_exclusive (is_exclusive),
  INDEX idx_session_attributes_display_name (display_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='セッション属性マスタテーブル';
```

**属性説明:**
- `id`: 主キー、自動増分
- `name`: 属性名（英字、システム内識別子）
- `display_name`: 表示名（日本語、UI表示用）
- `description`: 属性の説明
- `is_exclusive`: 排他属性フラグ（trueの場合他属性と共存不可）
- `config_schema`: 属性固有設定のJSONスキーマ

### talk_session_attributes (Talk-属性中間テーブル)

```sql
CREATE TABLE talk_session_attributes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  talk_id BIGINT NOT NULL,
  session_attribute_id BIGINT UNSIGNED NOT NULL,
  config_data JSON,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE KEY uk_talk_session_attrs (talk_id, session_attribute_id),
  
  -- Indexes
  INDEX idx_talk_session_attrs_talk (talk_id),
  INDEX idx_talk_session_attrs_attr (session_attribute_id),
  INDEX idx_talk_session_attrs_created (created_at),
  
  -- Foreign Keys
  FOREIGN KEY fk_talk_session_attrs_talk (talk_id) 
    REFERENCES talks(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY fk_talk_session_attrs_attr (session_attribute_id) 
    REFERENCES session_attributes(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='Talk-セッション属性関連付けテーブル';
```

**属性説明:**
- `id`: 主キー、自動増分
- `talk_id`: 対象Talk ID（外部キー）
- `session_attribute_id`: セッション属性ID（外部キー）
- `config_data`: 属性固有の設定データ（JSON）

## Extended Schema

### talks テーブルへの影響

```sql
-- 既存のtalksテーブルは維持（段階的移行のため）
-- 将来的にクリーンアップ予定のカラム:
-- - type (STI用、段階的に廃止)
-- - 既存のsponsor_id, abstractによる判定は並行利用

ALTER TABLE talks 
ADD COLUMN legacy_migration_complete BOOLEAN DEFAULT FALSE
COMMENT '新しいセッション属性システムへの移行完了フラグ';

-- インデックス追加
CREATE INDEX idx_talks_legacy_migration ON talks(legacy_migration_complete);
```

## Master Data Schema

### 初期セッション属性定義

```sql
-- マスタデータ投入
INSERT INTO session_attributes (id, name, display_name, description, is_exclusive, config_schema) VALUES
(1, 'keynote', 'キーノート', 'メインの基調講演', FALSE, JSON_OBJECT(
  'type', 'object',
  'properties', JSON_OBJECT(
    'keynote_type', JSON_OBJECT(
      'type', 'string',
      'enum', JSON_ARRAY('opening', 'closing', 'main'),
      'default', 'main',
      'description', 'キーノートの種類'
    ),
    'speaker_fee', JSON_OBJECT(
      'type', 'number',
      'minimum', 0,
      'description', '講演料（円）'
    ),
    'vip_treatment', JSON_OBJECT(
      'type', 'boolean',
      'default', FALSE,
      'description', 'VIP待遇の有無'
    )
  )
)),

(2, 'sponsor', 'スポンサーセッション', 'スポンサー企業によるセッション', FALSE, JSON_OBJECT(
  'type', 'object',
  'properties', JSON_OBJECT(
    'sponsorship_level', JSON_OBJECT(
      'type', 'string',
      'enum', JSON_ARRAY('platinum', 'gold', 'silver'),
      'default', 'silver',
      'description', 'スポンサーレベル'
    ),
    'contract_amount', JSON_OBJECT(
      'type', 'number',
      'minimum', 0,
      'description', '契約金額（円）'
    ),
    'booth_space', JSON_OBJECT(
      'type', 'integer',
      'minimum', 1,
      'description', 'ブーススペース（㎡）'
    )
  )
)),

(3, 'intermission', '休憩', '休憩時間', TRUE, JSON_OBJECT(
  'type', 'object',
  'properties', JSON_OBJECT(
    'duration_minutes', JSON_OBJECT(
      'type', 'integer',
      'minimum', 5,
      'maximum', 60,
      'default', 15,
      'description', '休憩時間（分）'
    ),
    'activity_type', JSON_OBJECT(
      'type', 'string',
      'enum', JSON_ARRAY('break', 'lunch', 'networking'),
      'default', 'break',
      'description', '休憩の種類'
    )
  )
)),

(4, 'lightning', 'ライトニングトーク', '短時間プレゼンテーション', FALSE, JSON_OBJECT(
  'type', 'object',
  'properties', JSON_OBJECT(
    'max_duration', JSON_OBJECT(
      'type', 'integer',
      'minimum', 1,
      'maximum', 10,
      'default', 5,
      'description', '最大発表時間（分）'
    ),
    'theme', JSON_OBJECT(
      'type', 'string',
      'description', '発表テーマ'
    )
  )
)),

(5, 'workshop', 'ワークショップ', 'ハンズオン形式のセッション', FALSE, JSON_OBJECT(
  'type', 'object',
  'properties', JSON_OBJECT(
    'capacity', JSON_OBJECT(
      'type', 'integer',
      'minimum', 1,
      'maximum', 100,
      'default', 30,
      'description', '定員'
    ),
    'skill_level', JSON_OBJECT(
      'type', 'string',
      'enum', JSON_ARRAY('beginner', 'intermediate', 'advanced'),
      'default', 'beginner',
      'description', '必要スキルレベル'
    ),
    'materials_provided', JSON_OBJECT(
      'type', 'boolean',
      'default', FALSE,
      'description', '資料配布の有無'
    )
  )
));
```

## Index Strategy

### パフォーマンス最適化のためのインデックス設計

```sql
-- 複合インデックス（頻繁な検索パターンに対応）

-- Talkの属性組み合わせ検索用
CREATE INDEX idx_talk_attrs_combo ON talk_session_attributes (
  talk_id, session_attribute_id
) COMMENT 'Talk-属性組み合わせ検索用';

-- 属性タイプ別検索用（session_attributes.nameでJOINする場合）
CREATE INDEX idx_session_attrs_name_id ON session_attributes (name, id) 
COMMENT '属性名による検索最適化';

-- 統計・レポート用
CREATE INDEX idx_talk_attrs_stats ON talk_session_attributes (
  session_attribute_id, created_at
) COMMENT '属性別統計・レポート用';

-- JSON設定値検索用（MySQLのGenerated Columnを活用）
ALTER TABLE talk_session_attributes 
ADD COLUMN keynote_type VARCHAR(20) GENERATED ALWAYS AS (
  JSON_UNQUOTE(JSON_EXTRACT(config_data, '$.keynote_type'))
) STORED;

CREATE INDEX idx_talk_attrs_keynote_type ON talk_session_attributes (keynote_type)
COMMENT 'キーノートタイプ別検索用';

ALTER TABLE talk_session_attributes 
ADD COLUMN sponsorship_level VARCHAR(20) GENERATED ALWAYS AS (
  JSON_UNQUOTE(JSON_EXTRACT(config_data, '$.sponsorship_level'))
) STORED;

CREATE INDEX idx_talk_attrs_sponsorship_level ON talk_session_attributes (sponsorship_level)
COMMENT 'スポンサーレベル別検索用';
```

## Query Patterns & Performance

### 典型的なクエリパターンと最適化

#### 1. 単一属性検索
```sql
-- キーノートセッション一覧
SELECT t.* 
FROM talks t
INNER JOIN talk_session_attributes tsa ON t.id = tsa.talk_id
INNER JOIN session_attributes sa ON tsa.session_attribute_id = sa.id
WHERE sa.name = 'keynote';

-- インデックス使用: idx_session_attrs_name, idx_talk_session_attrs_attr
```

#### 2. 複合属性検索
```sql  
-- スポンサーキーノート検索
SELECT t.* 
FROM talks t
WHERE t.id IN (
  SELECT tsa.talk_id 
  FROM talk_session_attributes tsa
  INNER JOIN session_attributes sa ON tsa.session_attribute_id = sa.id
  WHERE sa.name IN ('keynote', 'sponsor')
  GROUP BY tsa.talk_id
  HAVING COUNT(DISTINCT sa.name) = 2
);

-- インデックス使用: idx_talk_attrs_combo, idx_session_attrs_name_id
```

#### 3. 設定値による検索
```sql
-- ゴールドスポンサー検索
SELECT t.* 
FROM talks t
INNER JOIN talk_session_attributes tsa ON t.id = tsa.talk_id
WHERE tsa.sponsorship_level = 'gold';

-- インデックス使用: idx_talk_attrs_sponsorship_level
```

#### 4. 統計クエリ
```sql
-- 属性別セッション数
SELECT 
  sa.display_name,
  COUNT(tsa.id) as session_count,
  COUNT(DISTINCT tsa.talk_id) as unique_talks
FROM session_attributes sa
LEFT JOIN talk_session_attributes tsa ON sa.id = tsa.session_attribute_id
GROUP BY sa.id, sa.display_name
ORDER BY session_count DESC;

-- インデックス使用: idx_talk_session_attrs_attr
```

## Data Integrity & Constraints

### ビジネスルール制約

```sql
-- 1. 排他属性制約（Triggerまたはアプリケーションレベル）
DELIMITER //
CREATE TRIGGER tr_exclusive_attribute_check
BEFORE INSERT ON talk_session_attributes
FOR EACH ROW
BEGIN
  DECLARE exclusive_count INT DEFAULT 0;
  DECLARE current_is_exclusive BOOLEAN DEFAULT FALSE;
  
  -- 挿入しようとしている属性が排他的かチェック
  SELECT is_exclusive INTO current_is_exclusive
  FROM session_attributes 
  WHERE id = NEW.session_attribute_id;
  
  IF current_is_exclusive THEN
    -- 排他属性の場合、他の属性が存在しないかチェック
    SELECT COUNT(*) INTO exclusive_count
    FROM talk_session_attributes 
    WHERE talk_id = NEW.talk_id;
    
    IF exclusive_count > 0 THEN
      SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Exclusive attribute cannot coexist with other attributes';
    END IF;
  ELSE
    -- 非排他属性の場合、排他属性が存在しないかチェック
    SELECT COUNT(*) INTO exclusive_count
    FROM talk_session_attributes tsa
    INNER JOIN session_attributes sa ON tsa.session_attribute_id = sa.id
    WHERE tsa.talk_id = NEW.talk_id AND sa.is_exclusive = TRUE;
    
    IF exclusive_count > 0 THEN
      SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Cannot add attribute when exclusive attribute exists';
    END IF;
  END IF;
END//
DELIMITER ;

-- 2. JSON設定値制約（Check Constraint - MySQL 8.0+）
ALTER TABLE talk_session_attributes
ADD CONSTRAINT chk_config_data_valid
CHECK (JSON_VALID(config_data) OR config_data IS NULL);

-- 3. 参照整合性制約（既に定義済み）
-- FOREIGN KEY制約により、存在しないtalk_idやsession_attribute_idの参照を防ぐ
```

## Migration Strategy

### 段階的データ移行

```sql
-- Phase 1: 既存データの移行
INSERT INTO talk_session_attributes (talk_id, session_attribute_id, config_data)
SELECT 
  t.id as talk_id,
  1 as session_attribute_id, -- keynote
  JSON_OBJECT('keynote_type', 'main') as config_data
FROM talks t
WHERE t.type = 'KeynoteSession';

INSERT INTO talk_session_attributes (talk_id, session_attribute_id, config_data)
SELECT 
  t.id as talk_id,
  2 as session_attribute_id, -- sponsor
  JSON_OBJECT('sponsorship_level', 'silver') as config_data
FROM talks t
WHERE t.type = 'SponsorSession' OR t.sponsor_id IS NOT NULL;

INSERT INTO talk_session_attributes (talk_id, session_attribute_id, config_data)
SELECT 
  t.id as talk_id,
  3 as session_attribute_id, -- intermission
  JSON_OBJECT('duration_minutes', 15) as config_data
FROM talks t
WHERE t.type = 'Intermission' OR t.abstract = 'intermission';

-- Phase 2: 移行完了フラグの更新
UPDATE talks 
SET legacy_migration_complete = TRUE
WHERE id IN (
  SELECT DISTINCT talk_id 
  FROM talk_session_attributes
);
```

## Performance Monitoring

### 監視すべきメトリクス

```sql
-- 1. テーブルサイズ監視
SELECT 
  TABLE_NAME,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Size (MB)',
  TABLE_ROWS
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('session_attributes', 'talk_session_attributes');

-- 2. インデックス使用状況
SELECT 
  TABLE_NAME,
  INDEX_NAME,
  CARDINALITY,
  SUB_PART,
  PACKED,
  INDEX_TYPE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('session_attributes', 'talk_session_attributes')
ORDER BY TABLE_NAME, INDEX_NAME;

-- 3. クエリパフォーマンス監視用View
CREATE VIEW v_session_attribute_performance AS
SELECT 
  sa.name,
  sa.display_name,
  COUNT(tsa.id) as assignment_count,
  COUNT(DISTINCT tsa.talk_id) as unique_talks,
  AVG(LENGTH(tsa.config_data)) as avg_config_size
FROM session_attributes sa
LEFT JOIN talk_session_attributes tsa ON sa.id = tsa.session_attribute_id
GROUP BY sa.id, sa.name, sa.display_name;
```

## Backup & Recovery

### データ保護戦略

```sql
-- 1. 定期バックアップスクリプト
-- セッション属性関連テーブルの論理バックアップ
mysqldump --single-transaction --routines --triggers \
  dreamkast_production \
  session_attributes talk_session_attributes \
  > session_attributes_backup_$(date +%Y%m%d_%H%M%S).sql

-- 2. Point-in-time Recovery用設定
-- binlogの有効化とretention設定
SET GLOBAL binlog_expire_logs_seconds = 604800; -- 7日間保持

-- 3. データ整合性チェック
SELECT 
  'talk_session_attributes' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT talk_id) as unique_talks,
  COUNT(DISTINCT session_attribute_id) as unique_attributes
FROM talk_session_attributes
UNION ALL
SELECT 
  'session_attributes' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT name) as unique_names,
  SUM(CASE WHEN is_exclusive THEN 1 ELSE 0 END) as exclusive_count
FROM session_attributes;
```

このスキーマ設計により、セッション属性管理システムの堅牢で拡張可能なデータベース基盤が構築されます。