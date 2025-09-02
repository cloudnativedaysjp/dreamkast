namespace :util do
  desc 'recovery_checkin_stg'
  task recovery_checkin_stg: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    ActiveRecord::Base.logger.level = Logger::WARN

    conference = Conference.find_by(abbr: 'cndw2025')

    Profile.where(conference_id: conference.id).each do |profile|
      check_in = CheckInTalk.where(profile_id: profile.id).order(created_at: :asc).first
      next unless check_in

      puts "Profile: #{profile.id}, First CheckIn: #{check_in.created_at}"
    end
  end
end
