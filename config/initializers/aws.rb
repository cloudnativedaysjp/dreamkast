creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])

if ENV['AWS_ACCESS_KEY_ID']
  Aws::Rails.add_action_mailer_delivery_method(
    :ses,
    credentials: creds,
    region: 'ap-northeast-1'
  )
else
  Aws::Rails.add_action_mailer_delivery_method(
    :ses,
    region: 'ap-northeast-1'
  )
end

