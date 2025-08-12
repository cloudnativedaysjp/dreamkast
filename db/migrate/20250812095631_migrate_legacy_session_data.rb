class MigrateLegacySessionData < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    say_with_time "Migrating legacy session data to new session attributes system" do
      # Create temporary models for migration
      temp_session_attribute = Class.new(ActiveRecord::Base) do
        self.table_name = 'session_attributes'
      end
      
      temp_talk_session_attribute = Class.new(ActiveRecord::Base) do
        self.table_name = 'talk_session_attributes'
      end
      
      temp_talk = Class.new(ActiveRecord::Base) do
        self.table_name = 'talks'
      end
      
      # Find attribute IDs
      keynote_attr = temp_session_attribute.find_by(name: 'keynote')
      sponsor_attr = temp_session_attribute.find_by(name: 'sponsor')
      intermission_attr = temp_session_attribute.find_by(name: 'intermission')
      
      migrated_count = 0
      
      # Migrate KeynoteSession talks (if using STI)
      if temp_talk.column_names.include?('type')
        temp_talk.where(type: 'KeynoteSession').find_each do |talk|
          temp_talk_session_attribute.find_or_create_by!(
            talk_id: talk.id,
            session_attribute_id: keynote_attr.id
          )
          migrated_count += 1
        end
      end
      
      # Migrate SponsorSession talks (if using STI)
      if temp_talk.column_names.include?('type')
        temp_talk.where(type: 'SponsorSession').find_each do |talk|
          temp_talk_session_attribute.find_or_create_by!(
            talk_id: talk.id,
            session_attribute_id: sponsor_attr.id
          )
          migrated_count += 1
        end
      end
      
      # Migrate talks with sponsor_id
      temp_talk.where.not(sponsor_id: nil).find_each do |talk|
        # Skip if already migrated from STI
        next if temp_talk_session_attribute.exists?(
          talk_id: talk.id,
          session_attribute_id: sponsor_attr.id
        )
        
        temp_talk_session_attribute.find_or_create_by!(
          talk_id: talk.id,
          session_attribute_id: sponsor_attr.id
        )
        migrated_count += 1
      end
      
      # Migrate Intermission talks (if using STI)
      if temp_talk.column_names.include?('type')
        temp_talk.where(type: 'Intermission').find_each do |talk|
          temp_talk_session_attribute.find_or_create_by!(
            talk_id: talk.id,
            session_attribute_id: intermission_attr.id
          )
          migrated_count += 1
        end
      end
      
      # Migrate talks with abstract = 'intermission'
      temp_talk.where(abstract: 'intermission').find_each do |talk|
        # Skip if already migrated from STI
        next if temp_talk_session_attribute.exists?(
          talk_id: talk.id,
          session_attribute_id: intermission_attr.id
        )
        
        temp_talk_session_attribute.find_or_create_by!(
          talk_id: talk.id,
          session_attribute_id: intermission_attr.id
        )
        migrated_count += 1
      end
      
      say "Migrated #{migrated_count} session attributes"
    end
  end
  
  def down
    # Skip if running in test environment
    return if Rails.env.test?
    
    temp_talk_session_attribute = Class.new(ActiveRecord::Base) do
      self.table_name = 'talk_session_attributes'
    end
    
    temp_talk_session_attribute.delete_all
  end
end
