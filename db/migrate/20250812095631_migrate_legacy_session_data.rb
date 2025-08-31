class MigrateLegacySessionData < ActiveRecord::Migration[8.0]
  def up
    # Skip if running in test environment
    return if Rails.env.test?
    
    say_with_time "Migrating legacy session data to new session types system" do
      # Find type IDs
      regular_type = TalkType.find_by(id: 'Session')
      keynote_type = TalkType.find_by(id: 'KeynoteSession')
      sponsor_type = TalkType.find_by(id: 'SponsorSession')
      intermission_type = TalkType.find_by(id: 'Intermission')

      Talk.all.each do |talk|
        next_flag = false
        if talk.sponsor_session?
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: sponsor_type.id)
          next_flag = true
        end

        if talk.talk_category&.name == 'Keynote'
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: keynote_type.id)
          next_flag = true
        end

        if talk.abstract == 'intermission'
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: intermission_type.id)
          next_flag = true
        end

        next if next_flag

        case talk.type
        when 'Session'
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: regular_type.id)
        when "KeynoteSession"
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: keynote_type.id)
        when "SponsorSession"
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: sponsor_type.id)
        when "Intermission"
          TalkTypeAssociation.find_or_create_by(talk_id: talk.id, talk_type_id: intermission_type.id)
        end
      end
    end
  end
  
  def down
    # Skip if running in test environment
    return if Rails.env.test?
    
    TalkTypeAssociation.delete_all
  end
end
