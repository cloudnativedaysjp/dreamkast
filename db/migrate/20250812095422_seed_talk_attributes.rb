class SeedTalkAttributes < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    # Create TalkAttribute model temporarily for migration
    temp_talk_attribute = Class.new(ActiveRecord::Base) do
      self.table_name = 'talk_attributes'
    end
    
    # Insert master data
    temp_talk_attribute.create!([
      {
        name: 'keynote',
        display_name: 'キーノート',
        description: 'メインの基調講演',
        is_exclusive: false
      },
      {
        name: 'sponsor',
        display_name: 'スポンサーセッション',
        description: 'スポンサー企業によるセッション',
        is_exclusive: false
      },
      {
        name: 'intermission',
        display_name: '休憩',
        description: '休憩時間',
        is_exclusive: true
      }
    ])
  end
  
  def down
    # Skip if running in test environment
    return if Rails.env.test?
    
    temp_talk_attribute = Class.new(ActiveRecord::Base) do
      self.table_name = 'talk_attributes'
    end
    
    temp_talk_attribute.where(name: ['keynote', 'sponsor', 'intermission']).destroy_all
  end
end
