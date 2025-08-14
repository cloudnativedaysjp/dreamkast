class SeedSessionAttributes < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    # Create SessionAttribute model temporarily for migration
    temp_session_attribute = Class.new(ActiveRecord::Base) do
      self.table_name = 'session_attributes'
    end
    
    # Insert master data
    temp_session_attribute.create!([
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
    
    temp_session_attribute = Class.new(ActiveRecord::Base) do
      self.table_name = 'session_attributes'
    end
    
    temp_session_attribute.where(name: ['keynote', 'sponsor', 'intermission']).destroy_all
  end
end
