require 'aws-sdk-cloudfront'

module CloudfrontHelper
  def cloudfront_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    @cloudfront_client ||= if creds.set?
                             Aws::CloudFront::Client.new(region: AWS_LIVE_STREAM_REGION, credentials: creds)
                           else
                             Aws::CloudFront::Client.new(region: AWS_LIVE_STREAM_REGION)
                           end
  end

  def distribution_id
    case env_name
    when 'production'
      'E1EUIBAFETGIJ'
    when 'staging'
      'E1OOZSXNTOSVBA'
    else
      'E3NSOGUAIY8KVB'
    end
  end
end
