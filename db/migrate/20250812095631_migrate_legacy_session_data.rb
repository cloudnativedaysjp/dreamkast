class MigrateLegacySessionData < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    say_with_time "Migrating legacy session data to new session attributes system" do
      # Find attribute IDs
      regular_attr = TalkAttribute.find_by(name: 'regular')
      keynote_attr = TalkAttribute.find_by(name: 'keynote')
      sponsor_attr = TalkAttribute.find_by(name: 'sponsor')
      intermission_attr = TalkAttribute.find_by(name: 'intermission')

      Talk.all.each do |talk|
        case talk.type
        when 'Session'
          TalkAttributeAssociation.create!(talk_id:  talk.id, attribute_id: regular_attr.id)
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
    end
  end
  
  def down
    # Skip if running in test environment
    return if Rails.env.test?
    
    TalkAttributeAssociation.delete_all
  end
end
