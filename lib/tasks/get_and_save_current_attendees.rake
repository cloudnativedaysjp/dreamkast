namespace :util do
  desc 'get_and_save_current_attendees'
  task get_and_save_current_attendees: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    conferences = Conference.all
    puts conferences
    conferences.each do |conference|
      ivss = LiveStreamIvs.where(conference_id: conference.id)
      ivss.each do |ivs|
        begin
          count = ivs.viewer_count
          on_air = Talk.where(conference_id: conference.id, track_id: ivs.track_id).on_air
          if on_air.count > 0
            talk_id = on_air[0].id
          else
            talk_id = 0
          end

          vc = ViewerCount.new(
            conference_id: conference.id,
            track_id: ivs.track_id,
            stream_type: ivs.type,
            talk_id:,
            count:
          )
          vc.save!
        rescue Aws::IVS::Errors::ChannelNotBroadcasting
          puts(ivs.channel_arn + ' is not currently online')
        rescue => e
          puts('Unknown error' + e.to_s)
        end
      end
    end
  end
end
