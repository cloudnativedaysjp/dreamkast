namespace :util do
  desc 'cleanup_profiles'
  task cleanup_profiles: :environment do
    unless Rails.env.test?
      ActiveRecord::Base.logger = Logger.new($stdout)
      Rails.logger.level = Logger::DEBUG
    end

    abbr = ENV.fetch('EVENT_ABBR')

    ActiveRecord::Base.transaction do
      conference = Conference.find_by(abbr:)
      unless conference.archived? || conference.migrated?
        raise "#{conference.abbr} is not archived or migrated yet"
      end
      conference.profiles.each do |profile|
        RegisteredTalk.where(profile_id: profile.id).each(&:destroy!)
        ChatMessage.where(profile_id: profile.id).each do |chat_message|
          chat_message.update!(profile_id: nil)
        end
        CheckIn.where(profile_id: profile.id).each do |check_in|
          check_in.update!(profile_id: nil)
        end
        CheckInConference.where(scanner_profile_id: profile.id).update_all(scanner_profile_id: nil)
        CheckInTalk.where(scanner_profile_id: profile.id).update_all(scanner_profile_id: nil)
        CheckInConference.where(profile_id: profile.id).destroy_all
        CheckInTalk.where(profile_id: profile.id).destroy_all
        PublicProfile.where(profile_id: profile.id).destroy_all
        StampRallyCheckIn.where(profile_id: profile.id).delete_all
        FormValue.where(profile_id: profile.id).delete_all
        if ActiveRecord::Base.connection.table_exists?(:attendee_announcement_middles)
          ActiveRecord::Base.connection.exec_delete(
            ActiveRecord::Base.sanitize_sql_array(
              ['DELETE FROM attendee_announcement_middles WHERE profile_id = ?', profile.id]
            )
          )
        end
        profile.destroy!
      end
    end
  end
end
