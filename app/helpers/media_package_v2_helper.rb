require 'aws-sdk-mediapackage'

module MediaPackageV2Helper
  def media_package_v2_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    @client ||= if creds.set?
                  Aws::MediaPackageV2::Client.new(region: AWS_LIVE_STREAM_REGION, credentials: creds)
                else
                  Aws::MediaPackageV2::Client.new(region: AWS_LIVE_STREAM_REGION)
                end
  end

  def channel_group_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def channel_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def origin_endpoint_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
