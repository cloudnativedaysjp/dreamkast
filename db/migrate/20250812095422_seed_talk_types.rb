class SeedTalkTypes < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    # Create TalkType model temporarily for migration
    temp_talk_type = Class.new(ActiveRecord::Base) do
      self.table_name = 'talk_types'
    end
    
    # Skip if already seeded
    return if temp_talk_type.exists?(id: 'KeynoteSession')
    
    # Insert master data
    temp_talk_type.create!([
      {
        id: 'Session',
        display_name: '公募セッション',
        description: '公募セッション',
        is_exclusive: false
      },
      {
        id: 'KeynoteSession',
        display_name: 'キーノート',
        description: 'メインの基調講演',
        is_exclusive: false
      },
      {
        id: 'SponsorSession',
        display_name: 'スポンサーセッション',
        description: 'スポンサー企業によるセッション',
        is_exclusive: false
      },
      {
        id: 'Intermission',
        display_name: '休憩',
        description: '休憩時間',
        is_exclusive: true
      }
    ])
  end
  
  def down
    # Skip if running in test environment
    return if Rails.env.test?
    
    temp_talk_type = Class.new(ActiveRecord::Base) do
      self.table_name = 'talk_types'
    end
    
    temp_talk_type.where(id: ['Session', 'KeynoteSession', 'SponsorSession', 'Intermission']).destroy_all
  end
end
