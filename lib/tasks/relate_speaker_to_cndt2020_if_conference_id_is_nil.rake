namespace :db do
  desc 'relate_speaker_to_cndt2021_if_conference_id_is_nil'
  task relate_speaker_to_cndt2021_if_conference_id_is_nil: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    ActiveRecord::Base.transaction do
      begin
        p(Speaker.where(conference_id: nil).update_all(conference_id: 1))
      rescue => e
        puts(e)
      end
    end
  end
end
