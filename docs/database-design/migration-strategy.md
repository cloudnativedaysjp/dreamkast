# Migration Strategy

## Overview
既存のSTI（Single Table Inheritance）ベースシステムから新しい中間テーブルベースのセッション属性管理システムへの段階的移行戦略を詳述します。

## Migration Philosophy

### Zero-Downtime Principle
- **段階的移行**: 機能を段階的に切り替え、リスクを最小化
- **並行運用**: 旧システムと新システムを並行稼働
- **フォールバック**: 各段階でロールバック可能な設計
- **データ整合性**: 移行中も一貫したデータ状態を維持

### Compatibility-First Approach
- **後方互換性**: 既存APIとメソッドの動作保証
- **段階的廃止**: レガシーコードの計画的削除
- **移行期間**: 十分な検証期間の確保

## Migration Phases

### Phase 0: Pre-Migration Preparation (1 week)

#### 0.1 Current State Analysis
```ruby
# lib/tasks/migration_analysis.rake
namespace :session_migration do
  desc "Analyze current session data distribution"
  task analyze: :environment do
    puts "\n📊 Current Session Data Analysis"
    puts "=" * 50
    
    total_talks = Talk.count
    puts "Total Talks: #{total_talks}"
    
    # STI Type Distribution
    puts "\n🏷️  STI Type Distribution:"
    Talk.group(:type).count.each do |type, count|
      percentage = (count.to_f / total_talks * 100).round(2)
      puts "  #{type}: #{count} (#{percentage}%)"
    end
    
    # Sponsor Analysis
    sponsor_talks = Talk.where.not(sponsor_id: nil).count
    puts "\n💼 Sponsor Analysis:"
    puts "  With sponsor_id: #{sponsor_talks}"
    puts "  STI SponsorSession: #{Talk.where(type: 'SponsorSession').count}"
    
    # Intermission Analysis
    intermission_abstract = Talk.where(abstract: 'intermission').count
    intermission_type = Talk.where(type: 'Intermission').count
    puts "\n⏸️  Intermission Analysis:"
    puts "  abstract='intermission': #{intermission_abstract}"
    puts "  type='Intermission': #{intermission_type}"
    
    # Consistency Check
    puts "\n⚠️  Potential Inconsistencies:"
    sponsor_inconsistent = Talk.where(type: 'SponsorSession', sponsor_id: nil).count
    puts "  SponsorSession without sponsor_id: #{sponsor_inconsistent}"
    
    non_sponsor_with_sponsor = Talk.where.not(type: 'SponsorSession').where.not(sponsor_id: nil).count
    puts "  Non-SponsorSession with sponsor_id: #{non_sponsor_with_sponsor}"
  end
  
  desc "Validate data before migration"
  task validate: :environment do
    errors = []
    
    # Check for orphaned references
    orphaned_sponsors = Talk.joins('LEFT JOIN sponsors ON talks.sponsor_id = sponsors.id')
                           .where(sponsors: { id: nil })
                           .where.not(sponsor_id: nil)
                           .count
    
    errors << "Found #{orphaned_sponsors} talks with invalid sponsor_id" if orphaned_sponsors > 0
    
    # Check for invalid types
    valid_types = %w[Session KeynoteSession SponsorSession Intermission]
    invalid_types = Talk.where.not(type: valid_types).count
    errors << "Found #{invalid_types} talks with invalid type" if invalid_types > 0
    
    if errors.any?
      puts "❌ Data validation failed:"
      errors.each { |error| puts "  - #{error}" }
      exit 1
    else
      puts "✅ Data validation passed!"
    end
  end
end
```

#### 0.2 Backup Strategy
```bash
#!/bin/bash
# scripts/backup_before_migration.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/session_migration_${TIMESTAMP}"

mkdir -p $BACKUP_DIR

# Full database backup
mysqldump --single-transaction --routines --triggers \
  dreamkast_production > $BACKUP_DIR/full_backup.sql

# Talk table specific backup
mysqldump --single-transaction dreamkast_production talks \
  > $BACKUP_DIR/talks_backup.sql

# Related tables backup
mysqldump --single-transaction dreamkast_production \
  talk_types sponsors \
  > $BACKUP_DIR/related_tables_backup.sql

echo "Backup completed: $BACKUP_DIR"
```

### Phase 1: Foundation Setup (2 weeks)

#### 1.1 New Tables Creation
```ruby
# db/migrate/20250110000001_create_session_attributes_foundation.rb
class CreateSessionAttributesFoundation < ActiveRecord::Migration[7.0]
  def up
    # セッション属性マスタテーブル
    create_table :session_attributes do |t|
      t.string :name, limit: 50, null: false
      t.string :display_name, limit: 100, null: false
      t.text :description
      t.boolean :is_exclusive, default: false, null: false
      t.json :config_schema
      t.timestamps
      
      t.index :name, unique: true, name: 'uk_session_attributes_name'
      t.index :is_exclusive, name: 'idx_session_attributes_exclusive'
      t.index :display_name, name: 'idx_session_attributes_display_name'
    end
    
    # Talk-属性中間テーブル
    create_table :talk_session_attributes do |t|
      t.references :talk, null: false, foreign_key: { on_delete: :cascade }
      t.references :session_attribute, null: false, foreign_key: { on_delete: :cascade }
      t.json :config_data
      t.timestamps
      
      t.index [:talk_id, :session_attribute_id], 
              unique: true, 
              name: 'uk_talk_session_attrs'
      t.index :talk_id, name: 'idx_talk_session_attrs_talk'
      t.index :session_attribute_id, name: 'idx_talk_session_attrs_attr'
      t.index :created_at, name: 'idx_talk_session_attrs_created'
    end
    
    # 移行追跡用カラム
    add_column :talks, :session_migration_status, :string, default: 'pending'
    add_index :talks, :session_migration_status
    
    say "Session attributes foundation tables created"
  end
  
  def down
    drop_table :talk_session_attributes
    drop_table :session_attributes
    remove_column :talks, :session_migration_status
  end
end
```

#### 1.2 Master Data Seeding
```ruby
# db/migrate/20250110000002_seed_session_attributes.rb
class SeedSessionAttributes < ActiveRecord::Migration[7.0]
  def up
    session_attributes_data = [
      {
        name: 'keynote',
        display_name: 'キーノート',
        description: 'メインの基調講演',
        is_exclusive: false,
        config_schema: keynote_schema
      },
      {
        name: 'sponsor',
        display_name: 'スポンサーセッション',
        description: 'スポンサー企業によるセッション',
        is_exclusive: false,
        config_schema: sponsor_schema
      },
      {
        name: 'intermission',
        display_name: '休憩',
        description: '休憩時間',
        is_exclusive: true,
        config_schema: intermission_schema
      },
      {
        name: 'lightning',
        display_name: 'ライトニングトーク',
        description: '短時間プレゼンテーション',
        is_exclusive: false,
        config_schema: lightning_schema
      }
    ]
    
    session_attributes_data.each do |attrs|
      SessionAttribute.create!(attrs)
      say "Created session attribute: #{attrs[:name]}"
    end
  end
  
  def down
    SessionAttribute.destroy_all
  end
  
  private
  
  def keynote_schema
    {
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
  
  def sponsor_schema
    {
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
  
  def intermission_schema
    {
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
  
  def lightning_schema
    {
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
end
```

#### 1.3 Initial Data Migration
```ruby
# db/migrate/20250110000003_migrate_existing_session_data.rb
class MigrateExistingSessionData < ActiveRecord::Migration[7.0]
  def up
    keynote_attr = SessionAttribute.find_by!(name: 'keynote')
    sponsor_attr = SessionAttribute.find_by!(name: 'sponsor')
    intermission_attr = SessionAttribute.find_by!(name: 'intermission')
    
    migrated_count = 0
    
    # KeynoteSession migration
    Talk.where(type: 'KeynoteSession').find_in_batches(batch_size: 100) do |batch|
      batch.each do |talk|
        create_talk_session_attribute(
          talk: talk,
          attribute: keynote_attr,
          config: { keynote_type: 'main' }
        )
        migrated_count += 1
      end
    end
    
    # SponsorSession migration (by STI type)
    Talk.where(type: 'SponsorSession').find_in_batches(batch_size: 100) do |batch|
      batch.each do |talk|
        create_talk_session_attribute(
          talk: talk,
          attribute: sponsor_attr,
          config: { sponsorship_level: determine_sponsor_level(talk) }
        )
        migrated_count += 1
      end
    end
    
    # Additional sponsor sessions (by sponsor_id, not STI)
    Talk.where.not(sponsor_id: nil)
        .where.not(type: 'SponsorSession')
        .find_in_batches(batch_size: 100) do |batch|
      batch.each do |talk|
        create_talk_session_attribute(
          talk: talk,
          attribute: sponsor_attr,
          config: { sponsorship_level: determine_sponsor_level(talk) }
        )
        migrated_count += 1
      end
    end
    
    # Intermission migration
    Talk.where(type: 'Intermission')
        .or(Talk.where(abstract: 'intermission'))
        .find_in_batches(batch_size: 100) do |batch|
      batch.each do |talk|
        create_talk_session_attribute(
          talk: talk,
          attribute: intermission_attr,
          config: { duration_minutes: 15 }
        )
        migrated_count += 1
      end
    end
    
    say "Migrated #{migrated_count} session attributes"
    
    # Mark migrated talks
    Talk.joins(:talk_session_attributes)
        .update_all(session_migration_status: 'completed')
    
    # Mark remaining talks as no_attributes
    Talk.where(session_migration_status: 'pending')
        .update_all(session_migration_status: 'no_attributes')
    
    say "Migration status updated for all talks"
  end
  
  def down
    TalkSessionAttribute.delete_all
    Talk.update_all(session_migration_status: 'pending')
  end
  
  private
  
  def create_talk_session_attribute(talk:, attribute:, config:)
    # 重複チェック
    existing = TalkSessionAttribute.find_by(
      talk: talk,
      session_attribute: attribute
    )
    return if existing
    
    TalkSessionAttribute.create!(
      talk: talk,
      session_attribute: attribute,
      config_data: config
    )
  rescue ActiveRecord::RecordNotUnique
    # 並行実行での重複を無視
    nil
  end
  
  def determine_sponsor_level(talk)
    # スポンサーレベルを既存データから推定
    return 'silver' unless talk.sponsor
    
    case talk.sponsor.name.downcase
    when /platinum|diamond/
      'platinum'
    when /gold/
      'gold'
    else
      'silver'
    end
  end
end
```

### Phase 2: Model Integration (2 weeks)

#### 2.1 New Model Classes
```ruby
# app/models/session_attribute.rb
class SessionAttribute < ApplicationRecord
  has_many :talk_session_attributes, dependent: :destroy
  has_many :talks, through: :talk_session_attributes
  
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z_]+\z/ }
  validates :display_name, presence: true
  validates :config_schema, json_schema: true
  
  scope :exclusive, -> { where(is_exclusive: true) }
  scope :non_exclusive, -> { where(is_exclusive: false) }
  scope :ordered, -> { order(:display_name) }
  
  def self.keynote
    @keynote ||= find_by!(name: 'keynote')
  end
  
  def self.sponsor
    @sponsor ||= find_by!(name: 'sponsor')
  end
  
  def self.intermission
    @intermission ||= find_by!(name: 'intermission')
  end
  
  def default_config
    return {} unless config_schema&.dig('properties')
    
    defaults = {}
    config_schema['properties'].each do |key, property|
      defaults[key] = property['default'] if property.key?('default')
    end
    defaults
  end
end

# app/models/talk_session_attribute.rb  
class TalkSessionAttribute < ApplicationRecord
  belongs_to :talk
  belongs_to :session_attribute
  
  validates :talk_id, uniqueness: { scope: :session_attribute_id }
  validate :config_data_matches_schema
  validate :exclusive_attribute_check
  
  before_save :set_default_config_data
  after_save :update_migration_status
  after_destroy :update_migration_status
  
  private
  
  def config_data_matches_schema
    return unless session_attribute.config_schema.present?
    
    schema = JSONSchemer.schema(session_attribute.config_schema)
    unless schema.valid?(config_data || {})
      errors.add(:config_data, 'does not match the required schema')
    end
  end
  
  def exclusive_attribute_check
    return unless session_attribute.is_exclusive?
    
    other_attributes = talk.talk_session_attributes.where.not(id: id)
    if other_attributes.exists?
      errors.add(:session_attribute, 'exclusive attribute cannot coexist with others')
    end
  end
  
  def set_default_config_data
    return if config_data.present?
    self.config_data = session_attribute.default_config
  end
  
  def update_migration_status
    # 自動的に移行ステータスを更新
    if talk.talk_session_attributes.exists?
      talk.update_column(:session_migration_status, 'completed')
    else
      talk.update_column(:session_migration_status, 'no_attributes')
    end
  end
end
```

#### 2.2 Extended Talk Model
```ruby
# app/models/concerns/session_attribute_support.rb
module SessionAttributeSupport
  extend ActiveSupport::Concern
  
  included do
    has_many :talk_session_attributes, dependent: :destroy
    has_many :session_attributes, through: :talk_session_attributes
    
    # 新しいメソッド（v2として命名し、段階的に移行）
    def keynote_v2?
      session_attributes.exists?(name: 'keynote')
    end
    
    def sponsor_session_v2?
      session_attributes.exists?(name: 'sponsor')
    end
    
    def intermission_v2?
      session_attributes.exists?(name: 'intermission')
    end
    
    def lightning?
      session_attributes.exists?(name: 'lightning')
    end
    
    # 複合属性メソッド
    def sponsor_keynote?
      keynote_v2? && sponsor_session_v2?
    end
    
    # 設定取得メソッド
    def session_config(attribute_name)
      talk_session_attributes
        .joins(:session_attribute)
        .find_by(session_attributes: { name: attribute_name })
        &.config_data
    end
    
    # 一括設定メソッド
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
    
    # 新しいスコープ
    scope :with_session_attribute_v2, ->(name) {
      joins(:session_attributes).where(session_attributes: { name: name })
    }
    
    scope :keynotes_v2, -> { with_session_attribute_v2('keynote') }
    scope :sponsors_v2, -> { with_session_attribute_v2('sponsor') }
    scope :intermissions_v2, -> { with_session_attribute_v2('intermission') }
  end
end

# app/models/talk.rb - 既存ファイルに追加
class Talk < ApplicationRecord
  include SessionAttributeSupport
  
  # 既存のメソッドはPhase 3で段階的に更新
  # ...既存のコード...
end
```

#### 2.3 Backward Compatibility Layer
```ruby
# app/models/concerns/legacy_session_compatibility.rb
module LegacySessionCompatibility
  extend ActiveSupport::Concern
  
  included do
    # 既存メソッドの拡張（新旧両対応）
    def keynote?
      case session_migration_status
      when 'completed'
        keynote_v2?
      when 'partial'
        keynote_v2? || type == 'KeynoteSession'
      else
        type == 'KeynoteSession'
      end
    end
    
    def sponsor_session?
      case session_migration_status
      when 'completed'
        sponsor_session_v2?
      when 'partial'
        sponsor_session_v2? || sponsor.present?
      else
        sponsor.present? || type == 'SponsorSession'
      end
    end
    
    def intermission?
      case session_migration_status
      when 'completed'
        intermission_v2?
      when 'partial'
        intermission_v2? || legacy_intermission?
      else
        legacy_intermission?
      end
    end
    
    # レガシーメソッド
    def legacy_intermission?
      type == 'Intermission' || abstract == 'intermission'
    end
    
    # スコープの拡張
    scope :keynotes, -> {
      left_joins(:session_attributes)
        .where(
          session_attributes: { name: 'keynote' }
        ).or(where(type: 'KeynoteSession'))
        .distinct
    }
    
    scope :sponsor_sessions, -> {
      left_joins(:session_attributes)
        .where(
          session_attributes: { name: 'sponsor' }
        ).or(where.not(sponsor_id: nil))
        .distinct
    }
  end
end

# app/models/talk.rb に追加
class Talk < ApplicationRecord
  include LegacySessionCompatibility
  # ...
end
```

### Phase 3: Admin Interface Update (2 weeks)

#### 3.1 Controller Updates
```ruby
# app/controllers/admin/talks_controller.rb に追加
class Admin::TalksController < ApplicationController
  def update_talks
    success_count = 0
    error_count = 0
    
    Talk.transaction do
      # セッション属性の更新
      if params[:session_attributes].present?
        params[:session_attributes].each do |talk_id, attributes_data|
          talk = Talk.find(talk_id)
          
          if update_talk_session_attributes(talk, attributes_data)
            success_count += 1
          else
            error_count += 1
          end
        end
      end
      
      # 既存のビデオ設定更新
      TalksHelper.update_talks(@conference, params[:video]) if params[:video]
    end
    
    if error_count == 0
      redirect_to(admin_talks_url, notice: "#{success_count}件のセッション設定を更新しました")
    else
      redirect_to(admin_talks_url, 
                 alert: "#{error_count}件の更新に失敗しました（#{success_count}件は成功）")
    end
  end
  
  private
  
  def update_talk_session_attributes(talk, attributes_data)
    return true unless attributes_data[:attribute_ids].present?
    
    # 既存の属性をクリア
    talk.talk_session_attributes.destroy_all
    
    attribute_ids = attributes_data[:attribute_ids].reject(&:blank?)
    attribute_ids.each do |attr_id|
      attribute = SessionAttribute.find(attr_id)
      config_key = "config_#{attr_id}"
      config_data = attributes_data[config_key] || {}
      
      talk.talk_session_attributes.create!(
        session_attribute: attribute,
        config_data: config_data
      )
    end
    
    # 移行ステータスを更新
    talk.update!(session_migration_status: 'completed')
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to update session attributes for talk #{talk.id}: #{e.message}"
    false
  end
  
  def migration_progress
    total = @conference.talks.count
    completed = @conference.talks.where(session_migration_status: 'completed').count
    
    {
      total: total,
      completed: completed,
      percentage: total > 0 ? (completed.to_f / total * 100).round(1) : 0
    }
  end
  helper_method :migration_progress
end
```

#### 3.2 View Updates
```erb
<!-- app/views/admin/talks/index.html.erb - 移行進捗表示 -->
<div class="row mb-3">
  <div class="col-12">
    <div class="alert alert-info">
      <h6>セッション属性移行進捗</h6>
      <% progress = migration_progress %>
      <div class="progress">
        <div class="progress-bar" role="progressbar" 
             style="width: <%= progress[:percentage] %>%">
          <%= progress[:completed] %>/<%= progress[:total] %> 
          (<%= progress[:percentage] %>%)
        </div>
      </div>
    </div>
  </div>
</div>

<!-- 既存のテーブルに新しいセッション属性カラムを追加 -->
<table class="table table-striped talks_table">
  <thead>
    <tr>
      <th>ID</th>
      <th>セッション属性</th>
      <th>移行状況</th>
      <!-- 既存のカラム... -->
    </tr>
  </thead>
  <tbody>
    <%= form_with(url: admin_talks_path, method: "put") do |f| %>
      <% @talks.each do |talk| %>
        <tr class="<%= 'table-warning' if talk.session_migration_status == 'pending' %>">
          <td><%= talk.id %></td>
          <td>
            <%= render 'session_attributes_form', talk: talk %>
          </td>
          <td>
            <span class="badge bg-<%= migration_status_color(talk.session_migration_status) %>">
              <%= talk.session_migration_status.humanize %>
            </span>
          </td>
          <!-- 既存のカラム... -->
        </tr>
      <% end %>
    <% end %>
  </tbody>
</table>
```

#### 3.3 Partial Templates
```erb
<!-- app/views/admin/talks/_session_attributes_form.html.erb -->
<div class="session-attributes-wrapper" data-talk-id="<%= talk.id %>">
  <% SessionAttribute.ordered.each do |attr| %>
    <div class="form-check form-check-inline">
      <%= check_box_tag 
            "session_attributes[#{talk.id}][attribute_ids][]",
            attr.id,
            talk.session_attributes.include?(attr),
            {
              id: "talk_#{talk.id}_attr_#{attr.id}",
              class: "form-check-input session-attribute-checkbox",
              data: {
                talk_id: talk.id,
                attr_id: attr.id,
                exclusive: attr.is_exclusive?
              }
            } %>
      <%= label_tag "talk_#{talk.id}_attr_#{attr.id}", 
                    attr.display_name,
                    class: "form-check-label" %>
      
      <!-- 属性固有設定フォーム -->
      <% if attr.config_schema.present? && talk.session_attributes.include?(attr) %>
        <div class="attribute-config mt-1">
          <%= render 'session_attribute_config', 
                     talk: talk, 
                     attribute: attr %>
        </div>
      <% end %>
    </div>
  <% end %>
  <%= hidden_field_tag "session_attributes[#{talk.id}][attribute_ids][]", "" %>
</div>
```

### Phase 4: Testing & Validation (1 week)

#### 4.1 Data Validation Scripts
```ruby
# lib/tasks/migration_validation.rake
namespace :session_migration do
  desc "Validate migrated data integrity"
  task validate_data: :environment do
    puts "🔍 Validating Session Attribute Migration Data..."
    
    errors = []
    warnings = []
    
    # 1. 基本的な一貫性チェック
    Talk.includes(:session_attributes, :sponsor).find_each do |talk|
      case talk.session_migration_status
      when 'completed'
        # 移行完了とマークされているが属性が無いTalk
        if talk.session_attributes.empty?
          errors << "Talk #{talk.id}: marked as completed but has no attributes"
        end
        
        # スポンサーID vs スポンサー属性の一貫性
        has_sponsor_attr = talk.session_attributes.exists?(name: 'sponsor')
        has_sponsor_id = talk.sponsor_id.present?
        
        if has_sponsor_id && !has_sponsor_attr
          warnings << "Talk #{talk.id}: has sponsor_id but no sponsor attribute"
        elsif !has_sponsor_id && has_sponsor_attr
          warnings << "Talk #{talk.id}: has sponsor attribute but no sponsor_id"
        end
        
      when 'pending'
        # 移行待ちだがすでに属性があるTalk
        if talk.session_attributes.exists?
          warnings << "Talk #{talk.id}: marked as pending but has attributes"
        end
      end
      
      # 排他属性チェック
      exclusive_attrs = talk.session_attributes.where(is_exclusive: true)
      if exclusive_attrs.count > 1
        errors << "Talk #{talk.id}: has multiple exclusive attributes"
      elsif exclusive_attrs.exists? && talk.session_attributes.count > 1
        errors << "Talk #{talk.id}: exclusive attribute coexists with others"
      end
    end
    
    # 結果表示
    if errors.any?
      puts "❌ Validation Failed (#{errors.count} errors):"
      errors.each { |error| puts "  - #{error}" }
    end
    
    if warnings.any?
      puts "⚠️  Warnings (#{warnings.count}):"
      warnings.each { |warning| puts "  - #{warning}" }
    end
    
    if errors.empty?
      puts "✅ Data validation passed!"
      puts "📊 Migration Summary:"
      puts "  - Total talks: #{Talk.count}"
      puts "  - Completed: #{Talk.where(session_migration_status: 'completed').count}"
      puts "  - Pending: #{Talk.where(session_migration_status: 'pending').count}"
      puts "  - No attributes: #{Talk.where(session_migration_status: 'no_attributes').count}"
    end
  end
  
  desc "Compare legacy vs new attribute detection"
  task compare_methods: :environment do
    puts "🔄 Comparing Legacy vs New Attribute Detection..."
    
    inconsistencies = []
    
    Talk.includes(:session_attributes, :sponsor).limit(100).each do |talk|
      # KeynoteSessionの比較
      legacy_keynote = (talk.type == 'KeynoteSession')
      new_keynote = talk.keynote_v2?
      
      if legacy_keynote != new_keynote && talk.session_migration_status == 'completed'
        inconsistencies << "Talk #{talk.id}: keynote mismatch (legacy: #{legacy_keynote}, new: #{new_keynote})"
      end
      
      # スポンサーセッションの比較
      legacy_sponsor = talk.sponsor.present? || talk.type == 'SponsorSession'
      new_sponsor = talk.sponsor_session_v2?
      
      if legacy_sponsor != new_sponsor && talk.session_migration_status == 'completed'
        inconsistencies << "Talk #{talk.id}: sponsor mismatch (legacy: #{legacy_sponsor}, new: #{new_sponsor})"
      end
    end
    
    if inconsistencies.empty?
      puts "✅ No inconsistencies found!"
    else
      puts "❌ Found inconsistencies:"
      inconsistencies.each { |inc| puts "  - #{inc}" }
    end
  end
end
```

#### 4.2 Performance Testing
```ruby
# lib/tasks/migration_performance.rake
namespace :session_migration do
  desc "Test query performance before/after migration"
  task benchmark: :environment do
    require 'benchmark'
    
    puts "🚀 Performance Benchmark: Legacy vs New System"
    puts "=" * 50
    
    # テストデータセット
    sample_size = 1000
    talk_ids = Talk.limit(sample_size).pluck(:id)
    
    Benchmark.bm(30) do |bm|
      # Legacy queries
      bm.report("Legacy: Keynote sessions") do
        5.times { Talk.where(type: 'KeynoteSession').count }
      end
      
      bm.report("Legacy: Sponsor sessions") do
        5.times { Talk.where.not(sponsor_id: nil).count }
      end
      
      bm.report("Legacy: Individual check") do
        talk_ids.first(100).each { |id| Talk.find(id).sponsor.present? }
      end
      
      # New system queries
      bm.report("New: Keynote sessions") do
        5.times { Talk.keynotes_v2.count }
      end
      
      bm.report("New: Sponsor sessions") do
        5.times { Talk.sponsors_v2.count }
      end
      
      bm.report("New: Individual check") do
        talk_ids.first(100).each { |id| Talk.find(id).keynote_v2? }
      end
      
      # Complex queries
      bm.report("New: Sponsor keynotes") do
        5.times do
          Talk.joins(:session_attributes)
              .where(session_attributes: { name: ['keynote', 'sponsor'] })
              .group('talks.id')
              .having('COUNT(DISTINCT session_attributes.name) = 2')
              .count
        end
      end
    end
  end
end
```

### Phase 5: Gradual Rollout (2 weeks)

#### 5.1 Feature Flags
```ruby
# config/initializers/feature_flags.rb
class FeatureFlags
  def self.session_attributes_enabled?
    Rails.env.production? ? 
      ENV['SESSION_ATTRIBUTES_ENABLED'].present? : 
      true
  end
  
  def self.admin_ui_v2_enabled?
    Rails.env.production? ? 
      ENV['ADMIN_UI_V2_ENABLED'].present? : 
      true
  end
  
  def self.api_v2_enabled?
    Rails.env.production? ? 
      ENV['API_V2_ENABLED'].present? : 
      true
  end
end

# app/models/talk.rb での使用例
class Talk < ApplicationRecord
  def keynote?
    if FeatureFlags.session_attributes_enabled?
      # 新システムを使用
      case session_migration_status
      when 'completed'
        keynote_v2?
      else
        keynote_v2? || (type == 'KeynoteSession')
      end
    else
      # レガシーシステムを使用
      type == 'KeynoteSession'
    end
  end
end
```

#### 5.2 Monitoring & Alerting
```ruby
# app/controllers/concerns/session_migration_monitoring.rb
module SessionMigrationMonitoring
  extend ActiveSupport::Concern
  
  included do
    around_action :monitor_session_attribute_usage, 
                  only: [:index, :update_talks]
  end
  
  private
  
  def monitor_session_attribute_usage
    start_time = Time.current
    
    yield
    
    duration = Time.current - start_time
    
    # メトリクス送信
    if defined?(StatsD)
      StatsD.timing('admin.talks.session_attributes.request_duration', duration * 1000)
      StatsD.increment('admin.talks.session_attributes.requests')
    end
    
    # 遅いリクエストのログ
    if duration > 2.0
      Rails.logger.warn "[SLOW REQUEST] Session attributes operation took #{duration.round(3)}s"
    end
  end
end

# app/controllers/admin/talks_controller.rb
class Admin::TalksController < ApplicationController
  include SessionMigrationMonitoring
  # ...
end
```

#### 5.3 Rollback Preparation
```ruby
# lib/tasks/rollback_session_migration.rake
namespace :session_migration do
  desc "Rollback session attributes migration"
  task rollback: :environment do
    puts "⚠️  Rolling back session attributes migration..."
    
    confirmation = STDIN.gets.chomp
    unless confirmation.downcase == 'yes'
      puts "Rollback cancelled"
      exit 0
    end
    
    ActiveRecord::Base.transaction do
      # 1. Remove new system dependencies
      puts "Removing talk_session_attributes..."
      TalkSessionAttribute.delete_all
      
      # 2. Reset migration status
      puts "Resetting migration status..."
      Talk.update_all(session_migration_status: 'pending')
      
      # 3. Restore legacy behavior (code-level changes needed)
      puts "Legacy system restored. Code changes required:"
      puts "1. Disable FeatureFlags.session_attributes_enabled?"
      puts "2. Deploy previous version of Talk model"
      puts "3. Remove session attribute includes from queries"
    end
    
    puts "✅ Rollback completed!"
  end
  
  desc "Backup current state before rollback"
  task backup_current_state: :environment do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_file = "tmp/session_attributes_backup_#{timestamp}.json"
    
    backup_data = {
      timestamp: timestamp,
      session_attributes: SessionAttribute.all.as_json,
      talk_session_attributes: TalkSessionAttribute.includes(:talk, :session_attribute).as_json(
        include: {
          talk: { only: [:id, :title] },
          session_attribute: { only: [:id, :name] }
        }
      ),
      migration_status: Talk.group(:session_migration_status).count
    }
    
    File.write(backup_file, JSON.pretty_generate(backup_data))
    puts "Backup saved to: #{backup_file}"
  end
end
```

### Phase 6: Legacy Cleanup (1 week)

#### 6.1 Code Cleanup
```ruby
# lib/tasks/cleanup_legacy_code.rake
namespace :session_migration do
  desc "Remove legacy session management code"
  task cleanup_legacy: :environment do
    puts "🧹 Cleaning up legacy session management code..."
    
    # 1. Remove STI classes (manual step)
    puts "1. Remove STI class files:"
    puts "   - app/models/keynote_session.rb"
    puts "   - app/models/sponsor_session.rb" 
    puts "   - app/models/intermission.rb"
    puts "   - app/models/session.rb"
    
    # 2. Clean up Talk model
    puts "2. Remove from Talk model:"
    puts "   - Remove STI type column usage"
    puts "   - Remove legacy_intermission? method"
    puts "   - Rename keynote_v2? to keynote?"
    puts "   - Update all scopes to use new system"
    
    # 3. Database cleanup
    if Rails.env.development?
      puts "3. Database cleanup (development only):"
      
      # Remove unused columns after confirming they're no longer needed
      # remove_column :talks, :type  # Keep for now, remove in future
      
      # Drop legacy tables
      # drop_table :talk_types  # Keep for now, remove in future
      
      puts "   - Legacy columns marked for future removal"
    end
    
    puts "✅ Legacy cleanup guidelines provided!"
    puts "⚠️  Manual code changes required - see output above"
  end
end
```

## Risk Management

### Rollback Triggers
1. **Performance Degradation**: 20%以上の応答時間増加
2. **Data Inconsistency**: 移行データの不整合発見
3. **User Experience Issues**: Admin UI での操作困難
4. **Production Errors**: 新システム起因のエラー増加

### Monitoring Metrics
- Query performance: 移行前後の比較
- Error rates: 新機能関連のエラー率
- User activity: Admin画面での操作成功率
- Data consistency: 日次整合性チェック

### Communication Plan
- **Phase 1-2**: 開発チーム内での進捗共有
- **Phase 3**: ステークホルダーへの事前通知
- **Phase 4-5**: 本番適用とユーザーガイド提供
- **Phase 6**: 完了報告と今後の保守計画

この移行戦略により、安全で確実なセッション属性管理システムの導入が可能になります。