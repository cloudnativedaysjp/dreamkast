# Configure AWS SES for ActionMailer in the environment configuration files instead of here
# This initializer is kept for AWS configuration constants only

AWS_LIVE_STREAM_REGION = ENV.fetch('AWS_LIVE_STREAM_REGION', 'us-west-2')

# Register SES delivery method for ActionMailer
if defined?(ActionMailer)
  require 'aws-sdk-ses'

  ActionMailer::Base.add_delivery_method(:ses,
                                         Aws::SES::Client,
                                         region: ENV.fetch('AWS_SES_REGION', 'us-east-1'))
end
