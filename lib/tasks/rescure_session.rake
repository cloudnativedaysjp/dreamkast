namespace :util do
  desc 'rescue_session'
  task rescue_session: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    ActiveRecord::Base.logger.level = Logger::WARN

    json_data = File.read('tmp/checkin/checkinsession_day2.json')
    logs = JSON.parse(json_data)
    logs.each do |log|
      if log['line'] =~ /Parameters: (.*)/
        param_str = Regexp.last_match(1)
        # Convert Ruby hash string to JSON string
        json_str = param_str.gsub('=>', ':')
        begin
          params = JSON.parse(json_str)
          profile = Profile.find_by(id: params['profileId'])
          next unless profile

          puts profile.id.to_s + ' ' + Time.at(params['checkInTimestamp']).to_s + ' ' + params['talkId'].to_s
          CheckInTalk.create(profile_id: profile.id, talk_id: params['talkId'], check_in_timestamp: Time.at(params['checkInTimestamp']), scanner_profile_id: 48192)
        rescue JSON::ParserError => e
          puts "Failed to parse: #{json_str}"
        end
      end
    end
  end
end
