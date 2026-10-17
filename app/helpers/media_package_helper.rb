require 'aws-sdk-mediapackage'

module MediaPackageHelper
  def media_package_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::MediaPackage::Client.new(region: AWS_LIVE_STREAM_REGION, credentials: creds)
    else
      Aws::MediaPackage::Client.new(region: AWS_LIVE_STREAM_REGION)
    end
  end

  def resource_name
    conference = streaming.conference
    track = streaming.track

    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
