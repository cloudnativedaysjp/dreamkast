creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])

if ENV['AWS_ACCESS_KEY_ID']
  Aws::Rails.add_action_mailer_delivery_method(
    :ses,
    credentials: creds,
    region: 'us-west-2'
  )
else
  Aws::Rails.add_action_mailer_delivery_method(
    :ses,
    region: 'us-west-2'
  )
end

AWS_LIVE_STREAM_REGION = ENV.fetch('AWS_LIVE_STREAM_REGION', 'us-east-1')
