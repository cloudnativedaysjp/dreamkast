# Configure AWS SES for ActionMailer in the environment configuration files instead of here
# This initializer is kept for AWS configuration constants only

AWS_LIVE_STREAM_REGION = ENV.fetch('AWS_LIVE_STREAM_REGION', 'us-west-2')

# SES delivery method is provided by aws-actionmailer-ses gem
# Configuration is done in environment files using config.action_mailer.delivery_method = :ses
