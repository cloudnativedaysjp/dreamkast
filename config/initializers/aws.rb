p ENV['AWS_ACCESS_KEY_ID']
p ENV['AWS_SECRET_ACCESS_KEY']
creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])

Aws::Rails.add_action_mailer_delivery_method(
  :ses,
  credentials: creds,
  region: 'ap-northeast-1'
)

