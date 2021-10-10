namespace :util do
  desc "test"
  task test: :environment do
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    # Rails.logger.level = Logger::DEBUG

    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    ivs = Aws::IVS::Client.new(region: 'us-east-1', credentials: creds)
    s3 = Aws::S3::Client.new(region: 'us-east-1', credentials: creds)
    sts = Aws::STS::Client.new(region: 'us-east-1', credentials: creds)

    account_id = sts.get_caller_identity.account

    c = Conference.find(4)
    talk = c.talks.find{|talk| talk.live_stream_ivs.present? }

    live_stream_id = talk.live_stream_ivs.channel_arn.split('/')[1]
    bucket_name = ivs.get_recording_configuration(arn: talk.live_stream_ivs.recording_configuration_arn).recording_configuration.destination_configuration.s3.bucket_name

    resp = s3.list_objects_v2(bucket: bucket_name, prefix: "ivs/v1/#{account_id}/#{live_stream_id}/")

    resp.contents.each do |content|
      if content.key.end_with?('recording-ended.json')
        o = s3.get_object(bucket: bucket_name, key: content.key)
        info = JSON.parse(o.body.read)
        path = info['media']['hls']['path']
        info['media']['hls']['renditions'].each do |redition|
          p "#{content.key.sub(/\/events\/recording-ended.json/, '')}/#{path}/#{redition['path']}/#{redition['playlist']}"
        end
      end
    end
  end
end
