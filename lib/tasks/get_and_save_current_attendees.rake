namespace :util do
  desc "get_and_save_current_attendees"
  task get_and_save_current_attendees: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    conferences = Conference.all
    puts conferences
    conferences.each do |conference|
      ivss = LiveStreamIvs.where(conference_id: conference.id)
      ivss.each do |ivs|
        begin
          puts Talk.where(conference_id: conference.id, track_id: ivs.track_id).on_air
          puts ivs.viewer_count
        rescue Aws::IVS::Errors::ChannelNotBroadcasting
          puts ivs.channel_arn + " is not currently online"
        rescue
          puts "Unknown error"
        end
      end
    end
  end
end
