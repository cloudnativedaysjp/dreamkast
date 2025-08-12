# Data Integrity & Validation Strategy

## Overview
セッション属性管理システムにおけるデータ整合性とバリデーション戦略を定義します。多層防御アプローチにより、データの一貫性と正確性を保証します。

## Integrity Principles

### 1. Defense in Depth (多層防御)
- **Database Level**: 制約・トリガーによる強制
- **Application Level**: モデルバリデーション
- **API Level**: リクエストバリデーション
- **UI Level**: クライアント側チェック

### 2. ACID Compliance
- **Atomicity**: トランザクションによる原子性保証
- **Consistency**: 制約による一貫性維持
- **Isolation**: 同時実行制御
- **Durability**: 永続化の確実性

## Database Level Constraints

### Primary & Foreign Key Constraints

```sql
-- セッション属性マスタの制約
ALTER TABLE session_attributes
ADD CONSTRAINT pk_session_attributes PRIMARY KEY (id),
ADD CONSTRAINT uk_session_attributes_name UNIQUE (name);

-- Talk-属性中間テーブルの制約
ALTER TABLE talk_session_attributes
ADD CONSTRAINT pk_talk_session_attributes PRIMARY KEY (id),
ADD CONSTRAINT uk_talk_session_attrs UNIQUE (talk_id, session_attribute_id),
ADD CONSTRAINT fk_talk_session_attrs_talk 
    FOREIGN KEY (talk_id) REFERENCES talks(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_talk_session_attrs_attr 
    FOREIGN KEY (session_attribute_id) REFERENCES session_attributes(id) ON DELETE CASCADE;
```

### Check Constraints (MySQL 8.0+)

```sql
-- JSON形式の検証
ALTER TABLE talk_session_attributes
ADD CONSTRAINT chk_config_data_json 
    CHECK (JSON_VALID(config_data) OR config_data IS NULL);

-- セッション属性名の形式制約
ALTER TABLE session_attributes
ADD CONSTRAINT chk_session_attr_name_format 
    CHECK (name REGEXP '^[a-z][a-z0-9_]*$');

-- 表示名の長さ制約
ALTER TABLE session_attributes
ADD CONSTRAINT chk_display_name_length 
    CHECK (CHAR_LENGTH(display_name) BETWEEN 1 AND 100);

-- boolean値の制約
ALTER TABLE session_attributes
ADD CONSTRAINT chk_is_exclusive_boolean 
    CHECK (is_exclusive IN (0, 1));
```

### Database Triggers for Business Rules

```sql
-- 排他属性の制約を強制するトリガー
DELIMITER //

CREATE TRIGGER tr_exclusive_attribute_insert_check
BEFORE INSERT ON talk_session_attributes
FOR EACH ROW
BEGIN
    DECLARE exclusive_count INT DEFAULT 0;
    DECLARE current_is_exclusive BOOLEAN DEFAULT FALSE;
    DECLARE other_attrs_count INT DEFAULT 0;
    
    -- 挿入しようとしている属性が排他的かチェック
    SELECT is_exclusive INTO current_is_exclusive
    FROM session_attributes 
    WHERE id = NEW.session_attribute_id;
    
    IF current_is_exclusive THEN
        -- 排他属性の場合、同じTalkに他の属性が存在しないかチェック
        SELECT COUNT(*) INTO other_attrs_count
        FROM talk_session_attributes 
        WHERE talk_id = NEW.talk_id;
        
        IF other_attrs_count > 0 THEN
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

CREATE TRIGGER tr_exclusive_attribute_update_check
BEFORE UPDATE ON talk_session_attributes
FOR EACH ROW
BEGIN
    -- UPDATEでも同様のチェックを実行
    DECLARE exclusive_count INT DEFAULT 0;
    DECLARE current_is_exclusive BOOLEAN DEFAULT FALSE;
    DECLARE other_attrs_count INT DEFAULT 0;
    
    -- talk_idやsession_attribute_idが変更される場合のチェック
    IF NEW.talk_id != OLD.talk_id OR NEW.session_attribute_id != OLD.session_attribute_id THEN
        SELECT is_exclusive INTO current_is_exclusive
        FROM session_attributes 
        WHERE id = NEW.session_attribute_id;
        
        IF current_is_exclusive THEN
            SELECT COUNT(*) INTO other_attrs_count
            FROM talk_session_attributes 
            WHERE talk_id = NEW.talk_id AND id != NEW.id;
            
            IF other_attrs_count > 0 THEN
                SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Exclusive attribute cannot coexist with other attributes';
            END IF;
        ELSE
            SELECT COUNT(*) INTO exclusive_count
            FROM talk_session_attributes tsa
            INNER JOIN session_attributes sa ON tsa.session_attribute_id = sa.id
            WHERE tsa.talk_id = NEW.talk_id AND sa.is_exclusive = TRUE AND tsa.id != NEW.id;
            
            IF exclusive_count > 0 THEN
                SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Cannot add attribute when exclusive attribute exists';
            END IF;
        END IF;
    END IF;
END//

DELIMITER ;
```

### Audit Trail Triggers

```sql
-- 監査ログテーブル
CREATE TABLE session_attribute_audit_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id BIGINT NOT NULL,
    operation ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by VARCHAR(255),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_audit_table_record (table_name, record_id),
    INDEX idx_audit_operation (operation),
    INDEX idx_audit_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 監査トリガー
DELIMITER //

CREATE TRIGGER tr_session_attributes_audit_insert
AFTER INSERT ON session_attributes
FOR EACH ROW
BEGIN
    INSERT INTO session_attribute_audit_log (
        table_name, record_id, operation, new_values, changed_by
    ) VALUES (
        'session_attributes',
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'name', NEW.name,
            'display_name', NEW.display_name,
            'is_exclusive', NEW.is_exclusive,
            'config_schema', NEW.config_schema
        ),
        USER()
    );
END//

CREATE TRIGGER tr_talk_session_attributes_audit_insert
AFTER INSERT ON talk_session_attributes
FOR EACH ROW
BEGIN
    INSERT INTO session_attribute_audit_log (
        table_name, record_id, operation, new_values, changed_by
    ) VALUES (
        'talk_session_attributes',
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'talk_id', NEW.talk_id,
            'session_attribute_id', NEW.session_attribute_id,
            'config_data', NEW.config_data
        ),
        USER()
    );
END//

CREATE TRIGGER tr_talk_session_attributes_audit_delete
AFTER DELETE ON talk_session_attributes
FOR EACH ROW
BEGIN
    INSERT INTO session_attribute_audit_log (
        table_name, record_id, operation, old_values, changed_by
    ) VALUES (
        'talk_session_attributes',
        OLD.id,
        'DELETE',
        JSON_OBJECT(
            'talk_id', OLD.talk_id,
            'session_attribute_id', OLD.session_attribute_id,
            'config_data', OLD.config_data
        ),
        USER()
    );
END//

DELIMITER ;
```

## Application Level Validation

### Model Validations

```ruby
# app/models/session_attribute.rb
class SessionAttribute < ApplicationRecord
  has_many :talk_session_attributes, dependent: :destroy
  has_many :talks, through: :talk_session_attributes
  
  # 基本バリデーション
  validates :name, 
    presence: true,
    uniqueness: { case_sensitive: true },
    format: { 
      with: /\A[a-z][a-z0-9_]*\z/,
      message: 'must start with lowercase letter and contain only lowercase letters, numbers, and underscores'
    },
    length: { in: 2..50 }
  
  validates :display_name,
    presence: true,
    length: { in: 1..100 }
  
  validates :description,
    length: { maximum: 1000 },
    allow_blank: true
  
  validates :is_exclusive,
    inclusion: { in: [true, false] }
  
  validate :config_schema_is_valid_json_schema
  validate :config_schema_has_required_structure
  
  # カスタムバリデーション
  private
  
  def config_schema_is_valid_json_schema
    return if config_schema.blank?
    
    begin
      JSONSchemer.schema(config_schema)
    rescue JSON::ParserError, JSONSchemer::InvalidDocument => e
      errors.add(:config_schema, "is not a valid JSON Schema: #{e.message}")
    end
  end
  
  def config_schema_has_required_structure
    return if config_schema.blank?
    return unless config_schema.is_a?(Hash)
    
    unless config_schema['type'] == 'object'
      errors.add(:config_schema, 'must have type "object" at root level')
    end
    
    unless config_schema['properties'].is_a?(Hash)
      errors.add(:config_schema, 'must have "properties" object')
    end
  end
end

# app/models/talk_session_attribute.rb
class TalkSessionAttribute < ApplicationRecord
  belongs_to :talk
  belongs_to :session_attribute
  
  # 基本バリデーション
  validates :talk_id, 
    presence: true,
    uniqueness: { 
      scope: :session_attribute_id,
      message: 'already has this session attribute assigned'
    }
  
  validates :session_attribute_id, presence: true
  
  # カスタムバリデーション
  validate :config_data_matches_schema, if: :config_data_present?
  validate :exclusive_attribute_constraint
  validate :intermission_exclusive_constraint
  validate :config_data_is_valid_json, if: :config_data_present?
  
  # コールバック
  before_save :set_default_config_data
  after_save :sync_legacy_fields
  after_destroy :sync_legacy_fields
  
  private
  
  def config_data_present?
    config_data.present?
  end
  
  def config_data_is_valid_json
    return unless config_data.is_a?(String)
    
    begin
      JSON.parse(config_data)
    rescue JSON::ParserError
      errors.add(:config_data, 'must be valid JSON')
    end
  end
  
  def config_data_matches_schema
    schema_definition = session_attribute.config_schema
    return if schema_definition.blank?
    
    begin
      schema = JSONSchemer.schema(schema_definition)
      validation_result = schema.validate(config_data || {})
      
      unless validation_result.none?
        error_messages = validation_result.map { |error| error['error'] }
        errors.add(:config_data, "schema validation failed: #{error_messages.join(', ')}")
      end
    rescue => e
      errors.add(:config_data, "schema validation error: #{e.message}")
    end
  end
  
  def exclusive_attribute_constraint
    return unless session_attribute&.is_exclusive?
    
    other_attributes = talk.talk_session_attributes
                          .where.not(id: id)
                          .includes(:session_attribute)
    
    if other_attributes.exists?
      conflicting_names = other_attributes.map { |tsa| tsa.session_attribute.display_name }
      errors.add(:session_attribute, 
                "#{session_attribute.display_name} is exclusive and cannot coexist with: #{conflicting_names.join(', ')}")
    end
  end
  
  def intermission_exclusive_constraint
    return unless session_attribute&.name == 'intermission'
    
    other_non_intermission = talk.talk_session_attributes
                                .joins(:session_attribute)
                                .where.not(id: id)
                                .where.not(session_attributes: { name: 'intermission' })
    
    if other_non_intermission.exists?
      errors.add(:session_attribute, 'Intermission cannot coexist with other session attributes')
    end
  end
  
  def set_default_config_data
    return if config_data.present?
    return if session_attribute.config_schema.blank?
    
    self.config_data = session_attribute.default_config
  end
  
  def sync_legacy_fields
    # 既存フィールドとの同期（移行期間中の互換性のため）
    case session_attribute.name
    when 'intermission'
      if destroyed?
        talk.update_column(:abstract, nil) if talk.abstract == 'intermission'
      else
        talk.update_column(:abstract, 'intermission') unless talk.abstract == 'intermission'
      end
    end
  end
end
```

### Service Layer Validation

```ruby
# app/services/session_attribute_service.rb
class SessionAttributeService
  class ValidationError < StandardError; end
  
  def self.assign_attributes(talk, attribute_assignments)
    new(talk).assign_attributes(attribute_assignments)
  end
  
  def initialize(talk)
    @talk = talk
  end
  
  def assign_attributes(attribute_assignments)
    validate_attribute_assignments!(attribute_assignments)
    
    ActiveRecord::Base.transaction do
      # 既存の属性をクリア
      @talk.talk_session_attributes.destroy_all
      
      # 新しい属性を設定
      attribute_assignments.each do |assignment|
        create_talk_session_attribute!(assignment)
      end
    end
    
    @talk.reload
  end
  
  private
  
  def validate_attribute_assignments!(assignments)
    # 基本的な形式チェック
    raise ValidationError, 'Assignments must be an array' unless assignments.is_a?(Array)
    
    # 重複チェック
    attribute_names = assignments.map { |a| a[:name] }
    duplicates = attribute_names.select { |name| attribute_names.count(name) > 1 }.uniq
    raise ValidationError, "Duplicate attributes: #{duplicates.join(', ')}" if duplicates.any?
    
    # 排他属性チェック
    exclusive_attributes = assignments.select do |assignment|
      attr = SessionAttribute.find_by(name: assignment[:name])
      attr&.is_exclusive?
    end
    
    if exclusive_attributes.count > 1
      exclusive_names = exclusive_attributes.map { |a| a[:name] }
      raise ValidationError, "Multiple exclusive attributes: #{exclusive_names.join(', ')}"
    end
    
    if exclusive_attributes.any? && assignments.count > 1
      raise ValidationError, "Exclusive attribute cannot coexist with others"
    end
    
    # 属性の存在チェック
    assignments.each do |assignment|
      attr = SessionAttribute.find_by(name: assignment[:name])
      raise ValidationError, "Unknown attribute: #{assignment[:name]}" unless attr
    end
  end
  
  def create_talk_session_attribute!(assignment)
    attribute = SessionAttribute.find_by!(name: assignment[:name])
    
    @talk.talk_session_attributes.create!(
      session_attribute: attribute,
      config_data: assignment[:config] || {}
    )
  end
end
```

## API Level Validation

### Strong Parameters

```ruby
# app/controllers/admin/talks_controller.rb
class Admin::TalksController < ApplicationController
  private
  
  def session_attributes_params
    params.require(:session_attributes).permit!.to_h.tap do |permitted|
      # パラメータの構造検証
      permitted.each do |talk_id, talk_params|
        validate_talk_session_params!(talk_id, talk_params)
      end
    end
  end
  
  def validate_talk_session_params!(talk_id, params)
    # talk_idの妥当性
    begin
      Integer(talk_id)
    rescue ArgumentError
      raise ActionController::BadRequest, "Invalid talk_id: #{talk_id}"
    end
    
    # attribute_idsの構造チェック
    if params[:attribute_ids].present?
      attribute_ids = Array(params[:attribute_ids]).reject(&:blank?)
      
      # 数値IDの検証
      attribute_ids.each do |id|
        begin
          Integer(id)
        rescue ArgumentError
          raise ActionController::BadRequest, "Invalid attribute_id: #{id}"
        end
      end
      
      # 属性の存在確認
      existing_ids = SessionAttribute.where(id: attribute_ids).pluck(:id)
      missing_ids = attribute_ids.map(&:to_i) - existing_ids
      if missing_ids.any?
        raise ActionController::BadRequest, "Unknown attribute IDs: #{missing_ids.join(', ')}"
      end
    end
    
    # config_dataの構造チェック
    params.each do |key, value|
      next unless key.to_s.start_with?('config_')
      
      attr_id = key.to_s.gsub('config_', '').to_i
      attribute = SessionAttribute.find_by(id: attr_id)
      
      if attribute && value.present?
        validate_config_data!(attribute, value)
      end
    end
  end
  
  def validate_config_data!(attribute, config_data)
    return if attribute.config_schema.blank?
    
    begin
      schema = JSONSchemer.schema(attribute.config_schema)
      unless schema.valid?(config_data.to_h)
        error_details = schema.validate(config_data.to_h).map { |e| e['error'] }
        raise ActionController::BadRequest, 
              "Invalid config for #{attribute.name}: #{error_details.join(', ')}"
      end
    rescue => e
      raise ActionController::BadRequest, 
            "Config validation failed for #{attribute.name}: #{e.message}"
    end
  end
end
```

### API Input Sanitization

```ruby
# app/controllers/concerns/session_attribute_sanitization.rb
module SessionAttributeSanitization
  extend ActiveSupport::Concern
  
  private
  
  def sanitize_session_attribute_input(params)
    return {} unless params.is_a?(Hash)
    
    sanitized = {}
    
    params.each do |talk_id, talk_params|
      # talk_idの正規化
      normalized_talk_id = normalize_talk_id(talk_id)
      next unless normalized_talk_id
      
      sanitized[normalized_talk_id] = sanitize_talk_params(talk_params)
    end
    
    sanitized
  end
  
  def normalize_talk_id(talk_id)
    id = Integer(talk_id.to_s)
    id.positive? ? id : nil
  rescue ArgumentError
    nil
  end
  
  def sanitize_talk_params(params)
    return {} unless params.is_a?(Hash)
    
    sanitized = {}
    
    # attribute_idsの正規化
    if params[:attribute_ids].present?
      sanitized[:attribute_ids] = Array(params[:attribute_ids])
                                    .map(&:to_s)
                                    .reject(&:blank?)
                                    .map { |id| Integer(id) rescue nil }
                                    .compact
                                    .uniq
    end
    
    # config_dataの正規化
    params.each do |key, value|
      next unless key.to_s.start_with?('config_')
      
      attr_id = Integer(key.to_s.gsub('config_', '')) rescue next
      next unless SessionAttribute.exists?(attr_id)
      
      sanitized[key] = sanitize_config_data(value)
    end
    
    sanitized
  end
  
  def sanitize_config_data(data)
    return {} unless data.is_a?(Hash)
    
    # HTMLタグの除去
    sanitized = {}
    data.each do |key, value|
      case value
      when String
        sanitized[key] = ActionController::Base.helpers.strip_tags(value).strip
      when Numeric, TrueClass, FalseClass
        sanitized[key] = value
      when Array
        sanitized[key] = value.map do |item|
          item.is_a?(String) ? ActionController::Base.helpers.strip_tags(item).strip : item
        end
      end
    end
    
    sanitized
  end
end
```

## Business Logic Validation

### Complex Business Rules

```ruby
# app/validators/session_attribute_combination_validator.rb
class SessionAttributeCombinationValidator < ActiveModel::Validator
  def validate(record)
    return unless record.is_a?(Talk)
    
    validate_sponsor_keynote_rules(record)
    validate_workshop_capacity_rules(record)
    validate_lightning_talk_rules(record)
    validate_conference_specific_rules(record)
  end
  
  private
  
  def validate_sponsor_keynote_rules(talk)
    return unless talk.sponsor_keynote?
    
    # スポンサーキーノートのビジネスルール
    sponsor_config = talk.session_config('sponsor')
    keynote_config = talk.session_config('keynote')
    
    # プラチナスポンサー以上のみキーノート可能
    if sponsor_config&.dig('sponsorship_level') == 'silver'
      talk.errors.add(:base, 'Silver sponsors cannot have keynote sessions')
    end
    
    # オープニング・クロージングキーノートはスポンサー不可
    keynote_type = keynote_config&.dig('keynote_type')
    if ['opening', 'closing'].include?(keynote_type)
      talk.errors.add(:base, 'Opening/Closing keynotes cannot be sponsored')
    end
  end
  
  def validate_workshop_capacity_rules(talk)
    return unless talk.session_attributes.exists?(name: 'workshop')
    
    workshop_config = talk.session_config('workshop')
    capacity = workshop_config&.dig('capacity')
    
    # 会場の収容人数チェック
    if talk.track&.room&.number_of_seats
      room_capacity = talk.track.room.number_of_seats
      if capacity && capacity > room_capacity
        talk.errors.add(:base, "Workshop capacity (#{capacity}) exceeds room capacity (#{room_capacity})")
      end
    end
  end
  
  def validate_lightning_talk_rules(talk)
    return unless talk.session_attributes.exists?(name: 'lightning')
    
    # ライトニングトークは特定の時間枠のみ
    if talk.start_time && talk.end_time
      duration_minutes = (talk.end_time - talk.start_time) / 60
      max_duration = talk.session_config('lightning')&.dig('max_duration') || 5
      
      if duration_minutes > max_duration + 5  # 5分のバッファ
        talk.errors.add(:base, "Lightning talk duration (#{duration_minutes}min) exceeds maximum (#{max_duration}min)")
      end
    end
  end
  
  def validate_conference_specific_rules(talk)
    return unless talk.conference
    
    case talk.conference.abbr
    when 'cndt2024'
      validate_cndt2024_rules(talk)
    when 'cnds2024'
      validate_cnds2024_rules(talk)
    end
  end
  
  def validate_cndt2024_rules(talk)
    # CNDT2024固有のルール
    if talk.keynote? && talk.conference_day
      # キーノートは各日最大2つまで
      keynote_count = talk.conference_day.talks
                         .joins(:session_attributes)
                         .where(session_attributes: { name: 'keynote' })
                         .where.not(id: talk.id)
                         .count
      
      if keynote_count >= 2
        talk.errors.add(:base, 'Maximum 2 keynotes per day allowed')
      end
    end
  end
  
  def validate_cnds2024_rules(talk)
    # CNDS2024固有のルール（例）
    if talk.lightning?
      # ライトニングトークセッションのみで許可
      unless talk.title&.include?('Lightning')
        talk.errors.add(:base, 'Lightning talks must be in Lightning Talk sessions')
      end
    end
  end
end

# app/models/talk.rb に追加
class Talk < ApplicationRecord
  validates_with SessionAttributeCombinationValidator, on: :update
  # ...
end
```

## Monitoring & Alerting

### Data Quality Monitoring

```ruby
# app/services/data_integrity_monitor.rb
class DataIntegrityMonitor
  def self.check_all
    new.check_all
  end
  
  def check_all
    issues = []
    
    issues.concat(check_orphaned_attributes)
    issues.concat(check_exclusive_violations)
    issues.concat(check_schema_violations)
    issues.concat(check_legacy_sync_issues)
    
    if issues.any?
      notify_administrators(issues)
      Rails.logger.error "[DATA INTEGRITY] Found #{issues.count} issues"
    end
    
    issues
  end
  
  private
  
  def check_orphaned_attributes
    issues = []
    
    # 存在しないTalkを参照する属性
    orphaned_count = TalkSessionAttribute
      .joins('LEFT JOIN talks ON talk_session_attributes.talk_id = talks.id')
      .where(talks: { id: nil })
      .count
    
    if orphaned_count > 0
      issues << "Found #{orphaned_count} talk_session_attributes with invalid talk_id"
    end
    
    # 存在しないSessionAttributeを参照する属性  
    orphaned_attr_count = TalkSessionAttribute
      .joins('LEFT JOIN session_attributes ON talk_session_attributes.session_attribute_id = session_attributes.id')
      .where(session_attributes: { id: nil })
      .count
    
    if orphaned_attr_count > 0
      issues << "Found #{orphaned_attr_count} talk_session_attributes with invalid session_attribute_id"
    end
    
    issues
  end
  
  def check_exclusive_violations
    issues = []
    
    # 排他属性の違反チェック
    violation_talks = Talk
      .joins(talk_session_attributes: :session_attribute)
      .where(session_attributes: { is_exclusive: true })
      .joins('JOIN talk_session_attributes tsa2 ON talks.id = tsa2.talk_id')
      .where('tsa2.session_attribute_id != session_attributes.id')
      .select('DISTINCT talks.id, talks.title')
    
    violation_talks.each do |talk|
      issues << "Talk #{talk.id} (#{talk.title}) has exclusive attribute with other attributes"
    end
    
    issues
  end
  
  def check_schema_violations
    issues = []
    
    TalkSessionAttribute.includes(:session_attribute).find_each do |tsa|
      next if tsa.session_attribute.config_schema.blank?
      next if tsa.config_data.blank?
      
      begin
        schema = JSONSchemer.schema(tsa.session_attribute.config_schema)
        unless schema.valid?(tsa.config_data)
          issues << "TalkSessionAttribute #{tsa.id} has invalid config_data for attribute #{tsa.session_attribute.name}"
        end
      rescue => e
        issues << "TalkSessionAttribute #{tsa.id} schema validation error: #{e.message}"
      end
    end
    
    issues
  end
  
  def check_legacy_sync_issues
    issues = []
    
    # intermission同期チェック
    intermission_attr_talks = Talk
      .joins(:session_attributes)
      .where(session_attributes: { name: 'intermission' })
      .where.not(abstract: 'intermission')
    
    intermission_attr_talks.each do |talk|
      issues << "Talk #{talk.id} has intermission attribute but abstract != 'intermission'"
    end
    
    # sponsor同期チェック（警告レベル）
    sponsor_attr_talks = Talk
      .joins(:session_attributes)
      .where(session_attributes: { name: 'sponsor' })
      .where(sponsor_id: nil)
    
    if sponsor_attr_talks.count > 0
      issues << "WARNING: #{sponsor_attr_talks.count} talks have sponsor attribute but no sponsor_id"
    end
    
    issues
  end
  
  def notify_administrators(issues)
    # Slack通知
    if defined?(SlackNotifier)
      message = "🚨 Data Integrity Issues Detected:\n\n" + 
                issues.map { |issue| "• #{issue}" }.join("\n")
      
      SlackNotifier.notify(
        channel: '#alerts',
        message: message,
        username: 'Data Integrity Monitor'
      )
    end
    
    # メール通知
    if defined?(AdminMailer)
      AdminMailer.data_integrity_alert(issues).deliver_now
    end
  end
end
```

### Scheduled Monitoring Tasks

```ruby
# lib/tasks/data_integrity.rake
namespace :data_integrity do
  desc "Check data integrity for session attributes"
  task check: :environment do
    puts "🔍 Checking data integrity..."
    
    issues = DataIntegrityMonitor.check_all
    
    if issues.empty?
      puts "✅ No integrity issues found"
    else
      puts "❌ Found #{issues.count} issues:"
      issues.each { |issue| puts "  - #{issue}" }
      exit 1 if Rails.env.production?
    end
  end
  
  desc "Generate data quality report"
  task report: :environment do
    puts "\n📊 Session Attributes Data Quality Report"
    puts "=" * 60
    
    total_talks = Talk.count
    attributed_talks = Talk.joins(:session_attributes).distinct.count
    
    puts "📈 Coverage Statistics:"
    puts "  Total Talks: #{total_talks}"
    puts "  With Attributes: #{attributed_talks} (#{(attributed_talks.to_f / total_talks * 100).round(1)}%)"
    
    puts "\n🏷️  Attribute Distribution:"
    SessionAttribute.includes(:talk_session_attributes).order(:display_name).each do |attr|
      count = attr.talk_session_attributes.count
      percentage = total_talks > 0 ? (count.to_f / total_talks * 100).round(1) : 0
      puts "  #{attr.display_name}: #{count} (#{percentage}%)"
    end
    
    puts "\n🔗 Popular Combinations:"
    combination_stats = TalkSessionAttribute
      .joins(:talk, :session_attribute)
      .group('talks.id')
      .joins('JOIN session_attributes sa ON talk_session_attributes.session_attribute_id = sa.id')
      .group_by { |tsa| 
        Talk.find(tsa.talk_id).session_attributes.order(:name).pluck(:name).join(' + ') 
      }
      .transform_values(&:count)
      .sort_by { |_, count| -count }
      .first(10)
    
    combination_stats.each do |combination, count|
      puts "  #{combination}: #{count} talks"
    end
    
    puts "\n🚨 Data Quality Issues:"
    issues = DataIntegrityMonitor.new.check_all
    if issues.empty?
      puts "  ✅ No issues detected"
    else
      issues.each { |issue| puts "  ❌ #{issue}" }
    end
  end
end
```

### Real-time Monitoring

```ruby
# config/initializers/session_attributes_monitoring.rb
if Rails.env.production?
  # ActiveRecord通知の監視
  ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
    if payload[:sql].match?(/talk_session_attributes|session_attributes/)
      duration = finish - start
      
      # 遅いクエリの監視
      if duration > 0.5  # 500ms threshold
        Rails.logger.warn "[SLOW QUERY] Session Attributes: #{duration.round(3)}s - #{payload[:sql]}"
        
        # メトリクス送信
        if defined?(StatsD)
          StatsD.timing('database.session_attributes.slow_query', duration * 1000)
          StatsD.increment('database.session_attributes.slow_query_count')
        end
      end
    end
  end
  
  # エラー監視
  ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, start, finish, id, payload|
    if payload[:exception_object]
      exception = payload[:exception_object]
      
      # セッション属性関連のエラー
      if exception.message.match?(/session.?attribute|exclusive.?attribute/i) ||
         exception.backtrace.any? { |line| line.match?(/session_attribute/) }
        
        Rails.logger.error "[SESSION ATTR ERROR] #{exception.class}: #{exception.message}"
        
        if defined?(StatsD)
          StatsD.increment('application.session_attributes.error')
        end
      end
    end
  end
end
```

## Testing Strategy

### Integrity Testing

```ruby
# spec/support/shared_examples/data_integrity.rb
RSpec.shared_examples 'data integrity validation' do
  let(:talk) { create(:talk) }
  let(:keynote_attr) { create(:session_attribute, :keynote) }
  let(:sponsor_attr) { create(:session_attribute, :sponsor) }
  let(:intermission_attr) { create(:session_attribute, :intermission) }
  
  describe 'exclusive attribute constraints' do
    it 'prevents multiple exclusive attributes' do
      intermission1 = create(:session_attribute, name: 'intermission1', is_exclusive: true)
      intermission2 = create(:session_attribute, name: 'intermission2', is_exclusive: true)
      
      talk.session_attributes << intermission1
      
      expect {
        talk.session_attributes << intermission2
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    
    it 'prevents exclusive and non-exclusive coexistence' do
      talk.session_attributes << keynote_attr
      
      expect {
        talk.session_attributes << intermission_attr
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
  describe 'JSON schema validation' do
    it 'validates config_data against schema' do
      invalid_config = { keynote_type: 'invalid_type' }
      
      expect {
        TalkSessionAttribute.create!(
          talk: talk,
          session_attribute: keynote_attr,
          config_data: invalid_config
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    
    it 'accepts valid config_data' do
      valid_config = { keynote_type: 'main', speaker_fee: 100000 }
      
      expect {
        TalkSessionAttribute.create!(
          talk: talk,
          session_attribute: keynote_attr,
          config_data: valid_config
        )
      }.not_to raise_error
    end
  end
end

# spec/models/talk_session_attribute_spec.rb
RSpec.describe TalkSessionAttribute, type: :model do
  include_examples 'data integrity validation'
end
```

この包括的なデータ整合性・バリデーション戦略により、セッション属性管理システムの信頼性と一貫性が確保されます。