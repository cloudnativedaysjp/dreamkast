namespace :util do
  desc 'add unique_code to profile that unique_code is nil'
  task add_unique_code_to_profile: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    abbr = ENV.fetch('EVENT_ABBR')

    ActiveRecord::Base.transaction do
      conference = Conference.find_by(abbr:)
      conference.profiles
                .where(unique_code: nil)
                .update_all(unique_code: SecureRandom.uuid)
    end
  end
end
