# Implementation Plan

## Overview
中間テーブル方式によるセッション属性管理システムの実装計画です。段階的な実装により既存システムへの影響を最小限に抑えます。

## Implementation Phases

### Phase 1: Foundation Setup (2 weeks)

#### 1.1 Database Schema Creation
```ruby
# db/migrate/create_session_attributes.rb
class CreateSessionAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :session_attributes do |t|
      t.string :name, null: false, limit: 50
      t.string :display_name, null: false, limit: 100
      t.text :description
      t.boolean :is_exclusive, default: false, null: false
      t.json :config_schema
      t.timestamps
      
      t.index :name, unique: true
    end
    
    create_table :talk_session_attributes do |t|
      t.references :talk, null: false, foreign_key: true
      t.references :session_attribute, null: false, foreign_key: true
      t.json :config_data
      t.timestamps
      
      t.index [:talk_id, :session_attribute_id], 
              unique: true, 
              name: 'idx_talk_session_attrs_unique'
      t.index :talk_id, name: 'idx_talk_session_attrs_talk'
      t.index :session_attribute_id, name: 'idx_talk_session_attrs_attr'
    end
  end
end
```

#### 1.2 Seed Master Data
```ruby
# db/migrate/seed_session_attributes.rb
class SeedSessionAttributes < ActiveRecord::Migration[7.0]
  def up
    SessionAttribute.create!([
      {
        name: 'keynote',
        display_name: 'キーノート',
        description: 'メインの基調講演',
        is_exclusive: false,
        config_schema: {
          type: 'object',
          properties: {
            keynote_type: {
              type: 'string',
              enum: ['opening', 'closing', 'main'],
              default: 'main'
            },
            speaker_fee: {
              type: 'number',
              minimum: 0
            }
          }
        }
      },
      {
        name: 'sponsor',
        display_name: 'スポンサーセッション',
        description: 'スポンサー企業によるセッション',
        is_exclusive: false,
        config_schema: {
          type: 'object',
          properties: {
            sponsorship_level: {
              type: 'string',
              enum: ['platinum', 'gold', 'silver'],
              default: 'silver'
            },
            contract_amount: {
              type: 'number',
              minimum: 0
            }
          }
        }
      },
      {
        name: 'intermission',
        display_name: '休憩',
        description: '休憩時間',
        is_exclusive: true,
        config_schema: {
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
      },
      {
        name: 'lightning',
        display_name: 'ライトニングトーク',
        description: '短時間プレゼンテーション',
        is_exclusive: false,
        config_schema: {
          type: 'object',
          properties: {
            max_duration: {
              type: 'integer',
              default: 5
            }
          }
        }
      }
    ])
  end
  
  def down
    SessionAttribute.delete_all
  end
end
```

#### 1.3 Data Migration from Legacy System
```ruby
# db/migrate/migrate_legacy_session_data.rb
class MigrateLegacySessionData < ActiveRecord::Migration[7.0]
  def up
    keynote_attr = SessionAttribute.find_by!(name: 'keynote')
    sponsor_attr = SessionAttribute.find_by!(name: 'sponsor')
    intermission_attr = SessionAttribute.find_by!(name: 'intermission')
    
    # KeynoteSession -> keynote attribute
    Talk.where(type: 'KeynoteSession').find_each do |talk|
      TalkSessionAttribute.create!(
        talk: talk,
        session_attribute: keynote_attr,
        config_data: { keynote_type: 'main' }
      )
    end
    
    # SponsorSession or sponsor_id present -> sponsor attribute
    Talk.where(type: 'SponsorSession').or(
      Talk.where.not(sponsor_id: nil)
    ).find_each do |talk|
      TalkSessionAttribute.create!(
        talk: talk,
        session_attribute: sponsor_attr,
        config_data: { sponsorship_level: 'silver' }
      )
    end
    
    # Intermission by type or abstract
    Talk.where(type: 'Intermission').or(
      Talk.where(abstract: 'intermission')
    ).find_each do |talk|
      TalkSessionAttribute.create!(
        talk: talk,
        session_attribute: intermission_attr,
        config_data: { duration_minutes: 15 }
      )
    end
    
    say "Migrated #{TalkSessionAttribute.count} session attributes"
  end
  
  def down
    TalkSessionAttribute.delete_all
  end
end
```

#### 1.4 Basic Model Implementation
```ruby
# app/models/session_attribute.rb
class SessionAttribute < ApplicationRecord
  has_many :talk_session_attributes, dependent: :destroy
  has_many :talks, through: :talk_session_attributes
  
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z_]+\z/ }
  validates :display_name, presence: true
  validates :config_schema, presence: true
  
  scope :exclusive, -> { where(is_exclusive: true) }
  scope :non_exclusive, -> { where(is_exclusive: false) }
  
  def self.keynote
    find_by!(name: 'keynote')
  end
  
  def self.sponsor
    find_by!(name: 'sponsor')
  end
  
  def self.intermission
    find_by!(name: 'intermission')
  end
end

# app/models/talk_session_attribute.rb
class TalkSessionAttribute < ApplicationRecord
  belongs_to :talk
  belongs_to :session_attribute
  
  validates :talk_id, uniqueness: { scope: :session_attribute_id }
  validate :config_data_matches_schema
  validate :exclusive_attribute_check
  validate :intermission_exclusive_check
  
  before_save :set_default_config_data
  
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
    
    other_attributes = talk.talk_session_attributes
                          .joins(:session_attribute)
                          .where.not(id: id)
                          .where.not(session_attributes: { is_exclusive: true })
    
    if other_attributes.exists?
      errors.add(:session_attribute, 'exclusive attribute cannot coexist with others')
    end
  end
  
  def intermission_exclusive_check
    return unless session_attribute.name == 'intermission'
    
    other_attributes = talk.talk_session_attributes.where.not(id: id)
    if other_attributes.exists?
      errors.add(:session_attribute, 'intermission cannot coexist with other attributes')
    end
  end
  
  def set_default_config_data
    return if config_data.present?
    
    schema = session_attribute.config_schema
    return unless schema&.dig('properties')
    
    defaults = {}
    schema['properties'].each do |key, property|
      defaults[key] = property['default'] if property.key?('default')
    end
    
    self.config_data = defaults if defaults.any?
  end
end
```

#### 1.5 Extended Talk Model
```ruby
# app/models/talk.rb - 既存モデルに追加
class Talk < ApplicationRecord
  # ... 既存のコード ...
  
  # 新しい関連
  has_many :talk_session_attributes, dependent: :destroy
  has_many :session_attributes, through: :talk_session_attributes
  
  # 便利メソッド
  def keynote?
    session_attributes.exists?(name: 'keynote')
  end
  
  def sponsor_session?
    session_attributes.exists?(name: 'sponsor') || sponsor_id.present?
  end
  
  def sponsor_keynote?
    keynote? && sponsor_session?
  end
  
  def intermission?
    session_attributes.exists?(name: 'intermission') || 
      type == 'Intermission' || 
      abstract == 'intermission'
  end
  
  def lightning?
    session_attributes.exists?(name: 'lightning')
  end
  
  # 属性固有設定の取得
  def session_config(attribute_name)
    talk_session_attributes
      .joins(:session_attribute)
      .find_by(session_attributes: { name: attribute_name })
      &.config_data
  end
  
  # 新しいスコープ
  scope :with_session_attribute, ->(attribute_name) {
    joins(:session_attributes).where(session_attributes: { name: attribute_name })
  }
  
  scope :keynotes_v2, -> { with_session_attribute('keynote') }
  scope :sponsors_v2, -> { with_session_attribute('sponsor') }
  scope :intermissions_v2, -> { with_session_attribute('intermission') }
  
  scope :sponsor_keynotes, -> {
    joins(:session_attributes)
      .where(session_attributes: { name: ['keynote', 'sponsor'] })
      .group('talks.id')
      .having('COUNT(DISTINCT session_attributes.name) = 2')
  }
  
  # セッション属性の一括設定
  def set_session_attributes(attribute_names_with_config = {})
    transaction do
      talk_session_attributes.destroy_all
      
      attribute_names_with_config.each do |name, config|
        attribute = SessionAttribute.find_by!(name: name)
        talk_session_attributes.create!(
          session_attribute: attribute,
          config_data: config || {}
        )
      end
    end
  end
end
```

### Phase 2: Feature Implementation (3 weeks)

#### 2.1 Admin Controller Updates
```ruby
# app/controllers/admin/talks_controller.rb
class Admin::TalksController < ApplicationController
  # ... 既存のコード ...
  
  def update_talks
    Talk.transaction do
      # セッション属性の更新
      if params[:session_attributes].present?
        params[:session_attributes].each do |talk_id, attributes_data|
          talk = Talk.find(talk_id)
          update_talk_session_attributes(talk, attributes_data)
        end
      end
      
      # 既存のビデオ設定更新
      TalksHelper.update_talks(@conference, params[:video])
    end
    
    redirect_to(admin_talks_url, notice: 'セッション設定を更新しました')
  end
  
  private
  
  def update_talk_session_attributes(talk, attributes_data)
    # 既存の属性をクリア
    talk.talk_session_attributes.destroy_all
    
    # 新しい属性を設定
    return unless attributes_data[:attribute_ids].present?
    
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
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "セッション属性の更新に失敗しました: #{e.message}"
  end
end
```

#### 2.2 Admin View Updates
```erb
<!-- app/views/admin/talks/index.html.erb -->
<div class="row">
  <h2>Talks</h2>
  <table class="table table-striped talks_table">
    <thead>
      <tr>
        <th scope="col">ID</th>
        <th scope="col">セッション属性</th>
        <th scope="col">Speakers</th>
        <th scope="col">Title / Abstract</th>
        <!-- 既存カラム ... -->
      </tr>
    </thead>
    <tbody>
      <%= form_with(url: admin_talks_path, id: "talk_list", method: "put") do |f| %>
        <% @talks.each do |talk| %>
          <tr>
            <td><%= talk.id %></td>
            <td>
              <div class="session-attributes-wrapper" data-talk-id="<%= talk.id %>">
                <% SessionAttribute.order(:display_name).each do |attr| %>
                  <div class="form-check form-check-inline">
                    <%= check_box_tag 
                          "session_attributes[#{talk.id}][attribute_ids][]", 
                          attr.id,
                          talk.session_attributes.include?(attr),
                          {
                            id: "talk_#{talk.id}_attr_#{attr.id}",
                            class: "form-check-input session-attribute-checkbox",
                            data: { 
                              exclusive: attr.is_exclusive?,
                              talk_id: talk.id,
                              attr_id: attr.id
                            }
                          } %>
                    <%= label_tag 
                          "talk_#{talk.id}_attr_#{attr.id}", 
                          attr.display_name,
                          class: "form-check-label text-sm" %>
                  </div>
                <% end %>
                
                <!-- 属性固有の設定フォーム -->
                <div class="attribute-config-forms mt-2">
                  <% SessionAttribute.where.not(config_schema: nil).each do |attr| %>
                    <div id="config_form_<%= talk.id %>_<%= attr.id %>" 
                         class="attribute-config-form" 
                         style="display: none;">
                      <small class="text-muted"><%= attr.display_name %>設定:</small>
                      <% current_config = talk.session_config(attr.name) || {} %>
                      <% if attr.config_schema.dig('properties', 'keynote_type') %>
                        <%= select_tag 
                              "session_attributes[#{talk.id}][config_#{attr.id}][keynote_type]",
                              options_for_select([
                                ['メイン', 'main'],
                                ['オープニング', 'opening'],
                                ['クロージング', 'closing']
                              ], current_config['keynote_type']),
                              { class: 'form-select form-select-sm' } %>
                      <% elsif attr.config_schema.dig('properties', 'duration_minutes') %>
                        <%= number_field_tag 
                              "session_attributes[#{talk.id}][config_#{attr.id}][duration_minutes]",
                              current_config['duration_minutes'] || 15,
                              { min: 5, max: 60, class: 'form-control form-control-sm', style: 'width: 80px;' } %>
                        <span class="text-muted">分</span>
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </div>
              <%= hidden_field_tag "session_attributes[#{talk.id}][attribute_ids][]", "" %>
            </td>
            <td>
              <!-- 既存のSpeakerカラム -->
            </td>
            <!-- 他の既存カラム ... -->
          </tr>
        <% end %>
      <% end %>
    </tbody>
  </table>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // 排他制御とconfig表示/非表示の制御
  const sessionAttributeCheckboxes = document.querySelectorAll('.session-attribute-checkbox');
  
  sessionAttributeCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      const talkId = this.dataset.talkId;
      const attrId = this.dataset.attrId;
      const isExclusive = this.dataset.exclusive === 'true';
      const isChecked = this.checked;
      
      // 排他制御
      if (isExclusive && isChecked) {
        // 排他属性がチェックされたら他を全て外す
        const otherCheckboxes = document.querySelectorAll(
          `.session-attribute-checkbox[data-talk-id="${talkId}"]:not([data-attr-id="${attrId}"])`
        );
        otherCheckboxes.forEach(cb => cb.checked = false);
      } else if (isChecked) {
        // 通常属性がチェックされたら排他属性を外す
        const exclusiveCheckboxes = document.querySelectorAll(
          `.session-attribute-checkbox[data-talk-id="${talkId}"][data-exclusive="true"]`
        );
        exclusiveCheckboxes.forEach(cb => cb.checked = false);
      }
      
      // config formの表示/非表示
      const configForm = document.getElementById(`config_form_${talkId}_${attrId}`);
      if (configForm) {
        configForm.style.display = isChecked ? 'block' : 'none';
      }
      
      // 他のconfig formを非表示
      document.querySelectorAll(`.attribute-config-form[id^="config_form_${talkId}_"]:not(#config_form_${talkId}_${attrId})`).forEach(form => {
        if (!document.querySelector(`.session-attribute-checkbox[data-talk-id="${talkId}"][data-attr-id="${form.id.split('_').pop()}"]`).checked) {
          form.style.display = 'none';
        }
      });
    });
    
    // 初期状態の設定
    if (checkbox.checked) {
      const talkId = checkbox.dataset.talkId;
      const attrId = checkbox.dataset.attrId;
      const configForm = document.getElementById(`config_form_${talkId}_${attrId}`);
      if (configForm) {
        configForm.style.display = 'block';
      }
    }
  });
});
</script>
```

### Phase 3: Integration & Testing (2 weeks)

#### 3.1 Backward Compatibility Layer
```ruby
# app/models/concerns/legacy_session_support.rb
module LegacySessionSupport
  extend ActiveSupport::Concern
  
  included do
    # 既存メソッドとの互換性維持
    alias_method :sponsor_session_v2?, :sponsor_session?
    alias_method :intermission_v2?, :intermission?
    
    # 既存のsponsor_session?メソッドを拡張
    def sponsor_session?
      session_attributes.exists?(name: 'sponsor') || sponsor.present?
    end
    
    # 既存のintermission判定を拡張
    def intermission?
      session_attributes.exists?(name: 'intermission') || 
        type == 'Intermission' || 
        abstract == 'intermission'
    end
    
    # スコープの互換性
    scope :sponsor_legacy, -> { where.not(sponsor_id: nil) }
    scope :sponsor, -> { 
      left_joins(:session_attributes)
        .where(session_attributes: { name: 'sponsor' })
        .or(where.not(sponsor_id: nil))
    }
  end
end

# app/models/talk.rb
class Talk < ApplicationRecord
  include LegacySessionSupport
  # ... 既存のコード ...
end
```

#### 3.2 Testing Strategy
```ruby
# spec/models/talk_session_attribute_spec.rb
RSpec.describe TalkSessionAttribute, type: :model do
  let(:talk) { create(:talk) }
  let(:keynote_attr) { create(:session_attribute, :keynote) }
  let(:sponsor_attr) { create(:session_attribute, :sponsor) }
  let(:intermission_attr) { create(:session_attribute, :intermission) }
  
  describe 'validations' do
    it 'validates uniqueness of talk_id and session_attribute_id' do
      create(:talk_session_attribute, talk: talk, session_attribute: keynote_attr)
      
      duplicate = build(:talk_session_attribute, talk: talk, session_attribute: keynote_attr)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:talk_id]).to include('has already been taken')
    end
    
    it 'prevents exclusive attributes from coexisting' do
      create(:talk_session_attribute, talk: talk, session_attribute: keynote_attr)
      
      intermission_attr_assignment = build(:talk_session_attribute, 
                                          talk: talk, 
                                          session_attribute: intermission_attr)
      expect(intermission_attr_assignment).not_to be_valid
    end
  end
  
  describe 'config_data validation' do
    it 'validates against JSON schema' do
      invalid_config = { keynote_type: 'invalid_type' }
      
      talk_attr = build(:talk_session_attribute, 
                       talk: talk, 
                       session_attribute: keynote_attr,
                       config_data: invalid_config)
      
      expect(talk_attr).not_to be_valid
      expect(talk_attr.errors[:config_data]).to be_present
    end
  end
end

# spec/models/talk_spec.rb - 新しいメソッドのテスト
RSpec.describe Talk, type: :model do
  describe 'session attributes' do
    let(:talk) { create(:talk) }
    let(:keynote_attr) { create(:session_attribute, :keynote) }
    let(:sponsor_attr) { create(:session_attribute, :sponsor) }
    
    describe '#keynote?' do
      it 'returns true when keynote attribute is assigned' do
        talk.session_attributes << keynote_attr
        expect(talk.keynote?).to be true
      end
      
      it 'returns false when keynote attribute is not assigned' do
        expect(talk.keynote?).to be false
      end
    end
    
    describe '#sponsor_keynote?' do
      it 'returns true when both keynote and sponsor attributes are assigned' do
        talk.session_attributes << [keynote_attr, sponsor_attr]
        expect(talk.sponsor_keynote?).to be true
      end
      
      it 'returns false when only one attribute is assigned' do
        talk.session_attributes << keynote_attr
        expect(talk.sponsor_keynote?).to be false
      end
    end
    
    describe '#set_session_attributes' do
      it 'sets session attributes with config' do
        config = {
          'keynote' => { keynote_type: 'main' },
          'sponsor' => { sponsorship_level: 'gold' }
        }
        
        talk.set_session_attributes(config)
        
        expect(talk.keynote?).to be true
        expect(talk.sponsor_session?).to be true
        expect(talk.session_config('keynote')).to eq({ 'keynote_type' => 'main' })
      end
    end
  end
  
  describe 'backward compatibility' do
    it 'maintains existing sponsor_session? behavior' do
      # 既存のsponsor_id based detection
      sponsor_talk = create(:talk, sponsor: create(:sponsor))
      expect(sponsor_talk.sponsor_session?).to be true
      
      # 新しいattribute based detection
      attr_talk = create(:talk)
      attr_talk.session_attributes << create(:session_attribute, :sponsor)
      expect(attr_talk.sponsor_session?).to be true
    end
  end
end

# spec/features/admin_session_attributes_spec.rb
RSpec.describe 'Admin Session Attributes', type: :feature do
  let(:admin_user) { create(:admin_profile) }
  let(:conference) { create(:conference) }
  let(:talk) { create(:talk, conference: conference) }
  
  before do
    # Setup session attributes
    create(:session_attribute, :keynote)
    create(:session_attribute, :sponsor)
    create(:session_attribute, :intermission)
    
    # Login as admin
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin_user)
  end
  
  scenario 'Admin can set session attributes' do
    visit admin_talks_path
    
    # Check keynote checkbox
    check "talk_#{talk.id}_attr_keynote"
    
    # Check sponsor checkbox  
    check "talk_#{talk.id}_attr_sponsor"
    
    click_button '保存'
    
    expect(page).to have_content('セッション設定を更新しました')
    
    talk.reload
    expect(talk.keynote?).to be true
    expect(talk.sponsor_session?).to be true
    expect(talk.sponsor_keynote?).to be true
  end
  
  scenario 'Exclusive attributes prevent other selections' do
    visit admin_talks_path
    
    # Check keynote first
    check "talk_#{talk.id}_attr_keynote"
    
    # Check intermission (exclusive)
    check "talk_#{talk.id}_attr_intermission"
    
    # Keynote should be unchecked automatically
    expect(find("#talk_#{talk.id}_attr_keynote")).not_to be_checked
    expect(find("#talk_#{talk.id}_attr_intermission")).to be_checked
  end
end
```

### Phase 4: Migration & Cleanup (1 week)

#### 4.1 Production Data Validation
```ruby
# lib/tasks/validate_session_attributes.rake
namespace :session_attributes do
  desc "Validate migrated session attribute data"
  task validate: :environment do
    puts "Validating session attribute migration..."
    
    # Check data consistency
    inconsistencies = []
    
    Talk.includes(:session_attributes, :sponsor).find_each do |talk|
      # Check sponsor consistency
      has_sponsor_attr = talk.session_attributes.exists?(name: 'sponsor')
      has_sponsor_id = talk.sponsor_id.present?
      
      if has_sponsor_id && !has_sponsor_attr
        inconsistencies << "Talk #{talk.id}: has sponsor_id but no sponsor attribute"
      end
      
      # Check STI vs attribute consistency
      case talk.type
      when 'KeynoteSession'
        unless talk.session_attributes.exists?(name: 'keynote')
          inconsistencies << "Talk #{talk.id}: STI KeynoteSession but no keynote attribute"
        end
      when 'SponsorSession'
        unless talk.session_attributes.exists?(name: 'sponsor')
          inconsistencies << "Talk #{talk.id}: STI SponsorSession but no sponsor attribute"
        end
      when 'Intermission'
        unless talk.session_attributes.exists?(name: 'intermission')
          inconsistencies << "Talk #{talk.id}: STI Intermission but no intermission attribute"
        end
      end
    end
    
    if inconsistencies.any?
      puts "❌ Found #{inconsistencies.count} inconsistencies:"
      inconsistencies.each { |issue| puts "  - #{issue}" }
      exit 1
    else
      puts "✅ All session attributes are consistent!"
    end
  end
  
  desc "Generate migration report"
  task report: :environment do
    puts "\n📊 Session Attributes Migration Report"
    puts "=" * 50
    
    total_talks = Talk.count
    attributed_talks = Talk.joins(:session_attributes).distinct.count
    
    puts "Total Talks: #{total_talks}"
    puts "Talks with Attributes: #{attributed_talks}"
    puts "Coverage: #{((attributed_talks.to_f / total_talks) * 100).round(2)}%"
    
    puts "\n📈 Attribute Distribution:"
    SessionAttribute.includes(:talk_session_attributes).each do |attr|
      count = attr.talk_session_attributes.count
      percentage = ((count.to_f / total_talks) * 100).round(2)
      puts "  #{attr.display_name}: #{count} talks (#{percentage}%)"
    end
    
    # Combination analysis
    puts "\n🔗 Attribute Combinations:"
    combination_counts = TalkSessionAttribute
      .joins(:talk, :session_attribute)
      .group('talks.id')
      .joins('JOIN session_attributes sa ON talk_session_attributes.session_attribute_id = sa.id')
      .group_by { |tsa| tsa.talk.session_attributes.pluck(:name).sort.join(' + ') }
    
    combination_counts.each do |combination, talks|
      puts "  #{combination}: #{talks.count} talks"
    end
  end
end
```

#### 4.2 Performance Monitoring
```ruby
# config/initializers/session_attributes_monitoring.rb
if Rails.env.production?
  ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
    if payload[:sql].include?('talk_session_attributes') || 
       payload[:sql].include?('session_attributes')
      
      duration = finish - start
      if duration > 0.1 # 100ms threshold
        Rails.logger.warn "[SLOW QUERY] Session Attributes: #{duration.round(3)}s - #{payload[:sql]}"
      end
    end
  end
end
```

## Rollback Plan

### Emergency Rollback Procedure
```ruby
# db/migrate/rollback_session_attributes.rb
class RollbackSessionAttributes < ActiveRecord::Migration[7.0]
  def up
    say "Rolling back session attributes system..."
    
    # Restore legacy behavior
    Talk.transaction do
      # Reset type based on current attributes
      Talk.joins(:session_attributes).where(session_attributes: { name: 'keynote' }).update_all(type: 'KeynoteSession')
      Talk.joins(:session_attributes).where(session_attributes: { name: 'sponsor' }).update_all(type: 'SponsorSession')
      Talk.joins(:session_attributes).where(session_attributes: { name: 'intermission' }).update_all(type: 'Intermission')
      
      # Clean up new tables
      drop_table :talk_session_attributes
      drop_table :session_attributes
    end
    
    say "Rollback completed!"
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

## Success Metrics

### 1. Functional Metrics
- [ ] All existing session types correctly migrated
- [ ] New composite types (sponsor + keynote) working
- [ ] Admin UI functional and intuitive
- [ ] No data loss during migration

### 2. Performance Metrics
- [ ] Query performance within 10% of baseline
- [ ] Admin page load time under 2 seconds
- [ ] Database size increase under 5%

### 3. Quality Metrics
- [ ] Test coverage > 95%
- [ ] No critical bugs in production
- [ ] Zero downtime deployment
- [ ] Documentation complete

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|-----------------|
| Phase 1 | 2 weeks | Database schema, basic models, data migration |
| Phase 2 | 3 weeks | Admin UI, full feature implementation |
| Phase 3 | 2 weeks | Testing, integration, compatibility |
| Phase 4 | 1 week | Production deployment, monitoring |

**Total: 8 weeks**

## Risk Mitigation

1. **Data Loss Risk**: Comprehensive backup and validation procedures
2. **Performance Risk**: Gradual rollout with monitoring
3. **User Experience Risk**: Extensive testing with stakeholders
4. **Rollback Risk**: Detailed rollback procedures and testing

## Post-Implementation Tasks

- [ ] Monitor performance for 2 weeks
- [ ] Collect user feedback from admin users
- [ ] Update documentation and training materials
- [ ] Plan cleanup of legacy STI code (Phase 5)
- [ ] Evaluate additional session attributes based on usage