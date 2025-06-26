require Rails.root.join('app', 'helpers', 'env_helper')
require Rails.root.join('app', 'helpers', 'job_helper')
include JobHelper

# @see https://github.com/aws/aws-activejob-sqs-ruby/blob/v1.0.2/README.md#retry-behavior-and-handling-errors
# @see https://blog.smartbank.co.jp/entry/2025/06/12/aws-activejob-sqs
Aws::ActiveJob::SQS.configure do |config|
  config.poller_error_handler do |_exception, _sqs_message|
    # no-op, don't delete the message or re-raise the exception
  end
end
