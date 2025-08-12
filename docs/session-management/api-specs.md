# API Specifications

## Overview
新しいセッション属性管理システムのモデル、API、およびインターフェース仕様を定義します。

## Model Specifications

### SessionAttribute Model

```ruby
class SessionAttribute < ApplicationRecord
  # Attributes
  # id: bigint (primary key)
  # name: string(50), unique, not null
  # display_name: string(100), not null  
  # description: text
  # is_exclusive: boolean, default: false
  # config_schema: json
  # created_at: timestamp
  # updated_at: timestamp
  
  # Associations
  has_many :talk_session_attributes, dependent: :destroy
  has_many :talks, through: :talk_session_attributes
  
  # Validations
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z_]+\z/ }
  validates :display_name, presence: true
  validates :config_schema, json_schema: true
  
  # Scopes
  scope :exclusive, -> { where(is_exclusive: true) }
  scope :non_exclusive, -> { where(is_exclusive: false) }
  scope :ordered, -> { order(:display_name) }
  
  # Class methods
  def self.keynote
    find_by!(name: 'keynote')
  end
  
  def self.sponsor  
    find_by!(name: 'sponsor')
  end
  
  def self.intermission
    find_by!(name: 'intermission')
  end
  
  def self.lightning
    find_by!(name: 'lightning')
  end
  
  # Instance methods
  def config_properties
    config_schema&.dig('properties') || {}
  end
  
  def default_config
    defaults = {}
    config_properties.each do |key, property|
      defaults[key] = property['default'] if property.key?('default')
    end
    defaults
  end
  
  def validate_config_data(data)
    return true if config_schema.blank?
    
    schema = JSONSchemer.schema(config_schema)
    schema.valid?(data || {})
  end
end
```

### TalkSessionAttribute Model

```ruby
class TalkSessionAttribute < ApplicationRecord
  # Attributes
  # id: bigint (primary key)
  # talk_id: bigint, not null, foreign key
  # session_attribute_id: bigint, not null, foreign key
  # config_data: json
  # created_at: timestamp
  # updated_at: timestamp
  
  # Associations
  belongs_to :talk
  belongs_to :session_attribute
  
  # Validations
  validates :talk_id, uniqueness: { scope: :session_attribute_id }
  validate :config_data_matches_schema
  validate :exclusive_attribute_check
  
  # Callbacks
  before_save :set_default_config_data
  after_create :update_legacy_fields
  after_destroy :update_legacy_fields
  
  # Instance methods
  def config_value(key)
    config_data&.dig(key.to_s)
  end
  
  def set_config_value(key, value)
    self.config_data = (config_data || {}).merge(key.to_s => value)
  end
  
  private
  
  def config_data_matches_schema
    return if session_attribute.config_schema.blank?
    
    unless session_attribute.validate_config_data(config_data)
      errors.add(:config_data, 'does not match the required schema')
    end
  end
  
  def exclusive_attribute_check
    return unless session_attribute.is_exclusive?
    
    other_attributes = talk.talk_session_attributes
                          .where.not(id: id)
    
    if other_attributes.exists?
      errors.add(:session_attribute, 'exclusive attribute cannot coexist with others')
    end
  end
  
  def set_default_config_data
    return if config_data.present?
    self.config_data = session_attribute.default_config
  end
  
  def update_legacy_fields
    # 既存のフィールドとの同期（互換性のため）
    if session_attribute.name == 'intermission'
      talk.update_column(:abstract, destroyed? ? nil : 'intermission')
    end
  end
end
```

### Extended Talk Model Methods

```ruby
class Talk < ApplicationRecord
  # 新しい関連
  has_many :talk_session_attributes, dependent: :destroy
  has_many :session_attributes, through: :talk_session_attributes
  
  # セッション属性判定メソッド
  def keynote?
    session_attributes.exists?(name: 'keynote')
  end
  
  def sponsor_session?
    session_attributes.exists?(name: 'sponsor') || sponsor_id.present?
  end
  
  def intermission?
    session_attributes.exists?(name: 'intermission')
  end
  
  def lightning?
    session_attributes.exists?(name: 'lightning')
  end
  
  def workshop?
    session_attributes.exists?(name: 'workshop')
  end
  
  # 複合属性判定メソッド
  def sponsor_keynote?
    keynote? && sponsor_session?
  end
  
  def keynote_lightning?
    keynote? && lightning?
  end
  
  # 属性固有設定の取得
  def session_config(attribute_name)
    talk_session_attributes
      .joins(:session_attribute)
      .find_by(session_attributes: { name: attribute_name })
      &.config_data
  end
  
  def keynote_config
    session_config('keynote')
  end
  
  def sponsor_config
    session_config('sponsor')
  end
  
  # 設定値の便利メソッド
  def keynote_type
    keynote_config&.dig('keynote_type') || 'main'
  end
  
  def sponsorship_level
    sponsor_config&.dig('sponsorship_level') || 'silver'
  end
  
  def intermission_duration
    session_config('intermission')&.dig('duration_minutes') || 15
  end
  
  # セッション属性の一括設定
  def set_session_attributes(attributes_with_config = {})
    transaction do
      talk_session_attributes.destroy_all
      
      attributes_with_config.each do |name, config|
        attribute = SessionAttribute.find_by!(name: name.to_s)
        talk_session_attributes.create!(
          session_attribute: attribute,
          config_data: config || {}
        )
      end
    end
  end
  
  def add_session_attribute(name, config = {})
    attribute = SessionAttribute.find_by!(name: name.to_s)
    talk_session_attributes.find_or_create_by!(session_attribute: attribute) do |tsa|
      tsa.config_data = config
    end
  end
  
  def remove_session_attribute(name)
    talk_session_attributes
      .joins(:session_attribute)
      .where(session_attributes: { name: name.to_s })
      .destroy_all
  end
  
  # セッション属性の一覧取得
  def session_attribute_names
    session_attributes.pluck(:name)
  end
  
  def session_attribute_summary
    session_attributes.pluck(:name, :display_name).to_h
  end
  
  # 新しいスコープ
  scope :with_session_attribute, ->(name) {
    joins(:session_attributes).where(session_attributes: { name: name })
  }
  
  scope :without_session_attribute, ->(name) {
    left_joins(:session_attributes)
      .where(session_attributes: { name: [nil, name] })
      .where(session_attributes: { name: nil })
  }
  
  scope :keynotes_new, -> { with_session_attribute('keynote') }
  scope :sponsors_new, -> { with_session_attribute('sponsor') }
  scope :intermissions_new, -> { with_session_attribute('intermission') }
  scope :lightning_talks, -> { with_session_attribute('lightning') }
  
  scope :sponsor_keynotes, -> {
    joins(:session_attributes)
      .where(session_attributes: { name: ['keynote', 'sponsor'] })
      .group('talks.id')
      .having('COUNT(DISTINCT session_attributes.name) = 2')
  }
  
  scope :with_multiple_attributes, -> {
    joins(:session_attributes)
      .group('talks.id')  
      .having('COUNT(session_attributes.id) > 1')
  }
end
```

## JSON API Specifications

### GET /api/v1/session_attributes

セッション属性の一覧取得

**Response:**
```json
{
  "session_attributes": [
    {
      "id": 1,
      "name": "keynote",
      "display_name": "キーノート",
      "description": "メインの基調講演",
      "is_exclusive": false,
      "config_schema": {
        "type": "object",
        "properties": {
          "keynote_type": {
            "type": "string",
            "enum": ["opening", "closing", "main"],
            "default": "main"
          },
          "speaker_fee": {
            "type": "number",
            "minimum": 0
          }
        }
      }
    }
  ]
}
```

### GET /api/v1/talks/:id/session_attributes

特定のトークのセッション属性取得

**Response:**
```json
{
  "talk_id": 123,
  "session_attributes": [
    {
      "id": 1,
      "name": "keynote",
      "display_name": "キーノート",
      "config_data": {
        "keynote_type": "main",
        "speaker_fee": 100000
      }
    },
    {
      "id": 2,
      "name": "sponsor",
      "display_name": "スポンサーセッション",
      "config_data": {
        "sponsorship_level": "gold",
        "contract_amount": 500000
      }
    }
  ],
  "computed_properties": {
    "is_keynote": true,
    "is_sponsor_session": true,
    "is_sponsor_keynote": true,
    "is_intermission": false
  }
}
```

### PUT /api/v1/talks/:id/session_attributes

セッション属性の一括更新

**Request:**
```json
{
  "session_attributes": [
    {
      "name": "keynote",
      "config_data": {
        "keynote_type": "opening",
        "speaker_fee": 150000
      }
    },
    {
      "name": "sponsor",
      "config_data": {
        "sponsorship_level": "platinum"
      }
    }
  ]
}
```

**Response:**
```json
{
  "talk_id": 123,
  "updated_attributes": ["keynote", "sponsor"],
  "removed_attributes": [],
  "success": true
}
```

## Admin Interface Specifications

### Form Helper Methods

```ruby
module Admin::SessionAttributesHelper
  def session_attribute_checkboxes(talk, form_name = 'session_attributes')
    content_tag :div, class: 'session-attributes-form' do
      SessionAttribute.ordered.map do |attribute|
        session_attribute_checkbox(talk, attribute, form_name)
      end.join.html_safe
    end
  end
  
  def session_attribute_checkbox(talk, attribute, form_name)
    is_checked = talk.session_attributes.include?(attribute)
    checkbox_id = "#{form_name}_#{talk.id}_#{attribute.id}"
    
    content_tag :div, class: 'form-check' do
      concat check_box_tag("#{form_name}[#{talk.id}][attribute_ids][]",
                          attribute.id,
                          is_checked,
                          {
                            id: checkbox_id,
                            class: 'form-check-input session-attribute-checkbox',
                            data: {
                              exclusive: attribute.is_exclusive?,
                              talk_id: talk.id,
                              attr_id: attribute.id
                            }
                          })
      
      concat label_tag(checkbox_id, attribute.display_name, class: 'form-check-label')
      
      if attribute.config_schema.present? && is_checked
        concat session_attribute_config_form(talk, attribute, form_name)
      end
    end
  end
  
  def session_attribute_config_form(talk, attribute, form_name)
    current_config = talk.session_config(attribute.name) || {}
    
    content_tag :div, class: 'attribute-config mt-2' do
      attribute.config_properties.map do |key, property|
        config_field(talk.id, attribute.id, key, property, current_config[key], form_name)
      end.join.html_safe
    end
  end
  
  private
  
  def config_field(talk_id, attr_id, key, property, current_value, form_name)
    field_name = "#{form_name}[#{talk_id}][config_#{attr_id}][#{key}]"
    default_value = current_value || property['default']
    
    case property['type']
    when 'string'
      if property['enum']
        select_tag(field_name,
                  options_for_select(property['enum'].map { |v| [v, v] }, default_value),
                  class: 'form-select form-select-sm')
      else
        text_field_tag(field_name, default_value, class: 'form-control form-control-sm')
      end
    when 'number', 'integer'
      number_field_tag(field_name, 
                      default_value, 
                      {
                        min: property['minimum'],
                        max: property['maximum'],
                        class: 'form-control form-control-sm'
                      })
    when 'boolean'
      check_box_tag(field_name, '1', default_value, class: 'form-check-input')
    else
      text_field_tag(field_name, default_value, class: 'form-control form-control-sm')
    end
  end
end
```

### JavaScript Interface

```javascript
// app/javascript/admin/session_attributes.js
class SessionAttributesManager {
  constructor(container) {
    this.container = container;
    this.initEventListeners();
  }
  
  initEventListeners() {
    this.container.addEventListener('change', (event) => {
      if (event.target.classList.contains('session-attribute-checkbox')) {
        this.handleAttributeChange(event.target);
      }
    });
  }
  
  handleAttributeChange(checkbox) {
    const talkId = checkbox.dataset.talkId;
    const attrId = checkbox.dataset.attrId;
    const isExclusive = checkbox.dataset.exclusive === 'true';
    const isChecked = checkbox.checked;
    
    if (isExclusive && isChecked) {
      this.uncheckOtherAttributes(talkId, attrId);
    } else if (isChecked) {
      this.uncheckExclusiveAttributes(talkId);
    }
    
    this.toggleConfigForm(talkId, attrId, isChecked);
  }
  
  uncheckOtherAttributes(talkId, excludeAttrId) {
    const otherCheckboxes = this.container.querySelectorAll(
      `.session-attribute-checkbox[data-talk-id="${talkId}"]:not([data-attr-id="${excludeAttrId}"])`
    );
    
    otherCheckboxes.forEach(cb => {
      cb.checked = false;
      this.toggleConfigForm(talkId, cb.dataset.attrId, false);
    });
  }
  
  uncheckExclusiveAttributes(talkId) {
    const exclusiveCheckboxes = this.container.querySelectorAll(
      `.session-attribute-checkbox[data-talk-id="${talkId}"][data-exclusive="true"]`
    );
    
    exclusiveCheckboxes.forEach(cb => {
      cb.checked = false;
      this.toggleConfigForm(talkId, cb.dataset.attrId, false);
    });
  }
  
  toggleConfigForm(talkId, attrId, show) {
    const configForm = this.container.querySelector(
      `.attribute-config[data-talk-id="${talkId}"][data-attr-id="${attrId}"]`
    );
    
    if (configForm) {
      configForm.style.display = show ? 'block' : 'none';
    }
  }
  
  // Bulk operations
  selectAttributeForAll(attributeName) {
    const checkboxes = this.container.querySelectorAll(
      `.session-attribute-checkbox[data-attr-name="${attributeName}"]`
    );
    
    checkboxes.forEach(checkbox => {
      checkbox.checked = true;
      this.handleAttributeChange(checkbox);
    });
  }
  
  clearAllAttributes() {
    const checkboxes = this.container.querySelectorAll('.session-attribute-checkbox');
    
    checkboxes.forEach(checkbox => {
      checkbox.checked = false;
      this.handleAttributeChange(checkbox);
    });
  }
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
  const containers = document.querySelectorAll('.session-attributes-form');
  containers.forEach(container => {
    new SessionAttributesManager(container);
  });
});
```

## Database Schema

### Complete Schema Definition

```sql
-- セッション属性マスタテーブル
CREATE TABLE session_attributes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  display_name VARCHAR(100) NOT NULL,
  description TEXT,
  is_exclusive BOOLEAN NOT NULL DEFAULT FALSE,
  config_schema JSON,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  
  INDEX idx_session_attributes_name (name),
  INDEX idx_session_attributes_exclusive (is_exclusive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Talk-属性中間テーブル
CREATE TABLE talk_session_attributes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  talk_id BIGINT NOT NULL,
  session_attribute_id BIGINT UNSIGNED NOT NULL,
  config_data JSON,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  
  UNIQUE KEY idx_talk_session_attrs_unique (talk_id, session_attribute_id),
  INDEX idx_talk_session_attrs_talk (talk_id),
  INDEX idx_talk_session_attrs_attr (session_attribute_id),
  
  FOREIGN KEY (talk_id) REFERENCES talks(id) ON DELETE CASCADE,
  FOREIGN KEY (session_attribute_id) REFERENCES session_attributes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

### Master Data Seeds

```ruby
SessionAttribute.seed do |attr|
  attr.id = 1
  attr.name = 'keynote'
  attr.display_name = 'キーノート'
  attr.description = 'メインの基調講演'
  attr.is_exclusive = false
  attr.config_schema = {
    type: 'object',
    properties: {
      keynote_type: {
        type: 'string',
        enum: %w[opening closing main],
        default: 'main'
      },
      speaker_fee: {
        type: 'number',
        minimum: 0
      }
    }
  }
end

SessionAttribute.seed do |attr|
  attr.id = 2
  attr.name = 'sponsor'
  attr.display_name = 'スポンサーセッション'
  attr.description = 'スポンサー企業によるセッション'
  attr.is_exclusive = false
  attr.config_schema = {
    type: 'object',
    properties: {
      sponsorship_level: {
        type: 'string',
        enum: %w[platinum gold silver],
        default: 'silver'
      },
      contract_amount: {
        type: 'number',
        minimum: 0
      }
    }
  }
end

SessionAttribute.seed do |attr|
  attr.id = 3
  attr.name = 'intermission'
  attr.display_name = '休憩'
  attr.description = '休憩時間'
  attr.is_exclusive = true
  attr.config_schema = {
    type: 'object',
    properties: {
      duration_minutes: {
        type: 'integer',
        minimum: 5,
        maximum: 60,
        default: 15
      }
    }
  }
end

SessionAttribute.seed do |attr|
  attr.id = 4
  attr.name = 'lightning'
  attr.display_name = 'ライトニングトーク'
  attr.description = '短時間プレゼンテーション'
  attr.is_exclusive = false
  attr.config_schema = {
    type: 'object',
    properties: {
      max_duration: {
        type: 'integer',
        minimum: 1,
        maximum: 10,
        default: 5
      }
    }
  }
end
```

## Configuration Schema Examples

### Keynote Schema
```json
{
  "type": "object",
  "properties": {
    "keynote_type": {
      "type": "string",
      "enum": ["opening", "closing", "main"],
      "default": "main",
      "description": "キーノートの種類"
    },
    "speaker_fee": {
      "type": "number", 
      "minimum": 0,
      "description": "講演料（円）"
    },
    "vip_treatment": {
      "type": "boolean",
      "default": false,
      "description": "VIP待遇の有無"
    }
  }
}
```

### Sponsor Schema
```json
{
  "type": "object",
  "properties": {
    "sponsorship_level": {
      "type": "string",
      "enum": ["platinum", "gold", "silver"],
      "default": "silver",
      "description": "スポンサーレベル"
    },
    "contract_amount": {
      "type": "number",
      "minimum": 0,
      "description": "契約金額（円）"
    },
    "booth_space": {
      "type": "integer",
      "minimum": 1,
      "description": "ブーススペース（㎡）"
    }
  }
}
```

### Workshop Schema
```json
{
  "type": "object",
  "properties": {
    "capacity": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100,
      "default": 30,
      "description": "定員"
    },
    "requirements": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "必要な前提知識・準備"
    },
    "materials_provided": {
      "type": "boolean",
      "default": false,
      "description": "資料配布の有無"
    }
  }
}
```

## Testing Interface

### RSpec Shared Examples
```ruby
# spec/support/shared_examples/session_attributes.rb
RSpec.shared_examples 'session attribute validation' do |attribute_name|
  let(:attribute) { SessionAttribute.find_by!(name: attribute_name) }
  
  it "validates #{attribute_name} config schema" do
    valid_config = attribute.default_config
    invalid_config = { invalid_key: 'invalid_value' }
    
    valid_attr = build(:talk_session_attribute, 
                      session_attribute: attribute, 
                      config_data: valid_config)
    expect(valid_attr).to be_valid
    
    invalid_attr = build(:talk_session_attribute, 
                        session_attribute: attribute, 
                        config_data: invalid_config)
    expect(invalid_attr).not_to be_valid
  end
end

RSpec.shared_examples 'session attribute assignment' do |attribute_name|
  let(:attribute) { SessionAttribute.find_by!(name: attribute_name) }
  
  it "assigns and removes #{attribute_name} attribute" do
    talk.add_session_attribute(attribute_name)
    expect(talk.session_attributes).to include(attribute)
    expect(talk.send("#{attribute_name}?")).to be true
    
    talk.remove_session_attribute(attribute_name)
    talk.reload
    expect(talk.session_attributes).not_to include(attribute)
    expect(talk.send("#{attribute_name}?")).to be false
  end
end
```

### Factory Definitions
```ruby
# spec/factories/session_attributes.rb
FactoryBot.define do
  factory :session_attribute do
    sequence(:name) { |n| "attribute_#{n}" }
    sequence(:display_name) { |n| "Attribute #{n}" }
    is_exclusive { false }
    
    trait :keynote do
      name { 'keynote' }
      display_name { 'キーノート' }
      config_schema do
        {
          type: 'object',
          properties: {
            keynote_type: {
              type: 'string',
              enum: %w[opening closing main],
              default: 'main'
            }
          }
        }
      end
    end
    
    trait :sponsor do
      name { 'sponsor' }
      display_name { 'スポンサーセッション' }
      config_schema do
        {
          type: 'object',
          properties: {
            sponsorship_level: {
              type: 'string',
              enum: %w[platinum gold silver],
              default: 'silver'
            }
          }
        }
      end
    end
    
    trait :intermission do
      name { 'intermission' }
      display_name { '休憩' }
      is_exclusive { true }
      config_schema do
        {
          type: 'object',
          properties: {
            duration_minutes: {
              type: 'integer',
              default: 15
            }
          }
        }
      end
    end
  end
  
  factory :talk_session_attribute do
    association :talk
    association :session_attribute
    config_data { session_attribute.default_config }
  end
end
```

このAPI仕様により、セッション属性管理システムの全体的な構造と使用方法が明確に定義されています。