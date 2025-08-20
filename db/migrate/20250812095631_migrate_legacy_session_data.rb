class MigrateLegacySessionData < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    say_with_time "Migrating legacy session data to new session attributes system" do
      # Find attribute IDs
      keynote_attr = TalkAttribute.find_by(name: 'keynote')
      sponsor_attr = TalkAttribute.find_by(name: 'sponsor')
      intermission_attr = TalkAttribute.find_by(name: 'intermission')

      Talk.all.each do |talk|
        case talk.type
        when "KeynoteSession"
          TalkAttributeAssociation.create!(talk_id: talk.id, talk_attribute_id: keynote_attr.id)
          if talk.sponsor_session?
            TalkAttributeAssociation.create!(talk_id: talk.id, talk_attribute_id: sponsor_attr.id)
          end
        when "SponsorSession"
          TalkAttributeAssociation.create!(talk_id: talk.id, talk_attribute_id: sponsor_attr.id)
        when "Intermission"
          TalkAttributeAssociation.create!(talk_id: talk.id, talk_attribute_id: intermission_attr.id)
        end
      end
      say "Migrated #{migrated_count} session attributes"
    end
  end
  
  def down
    # Skip if running in test environment
    return if Rails.env.test?
    
    TalkAttributeAssociation.delete_all
  end
end
