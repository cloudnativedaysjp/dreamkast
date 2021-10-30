class LiveStreamIvs < LiveStream
  belongs_to :conference
  belongs_to :track

  before_create do
    resp = ivs_client.create_channel(
      name: "#{env_name_for_tag}_#{conference.abbr}_track#{track.name}",
      latency_mode: "LOW",
      type: "STANDARD",
      authorized: false,
      recording_configuration_arn: recording_configuration_arn,
      tags: {
        "Environment" => env_name_for_tag
      }
    )

    self.params = {
      channel: resp.channel,
      stream_key: resp.stream_key
    }
  end

  before_destroy do
    ivs_client.delete_channel(arn: channel_arn) if channel_arn
  rescue Aws::IVS::Errors::ResourceNotFoundException => e
    logger.error "IVS Resource Not Found: #{e.message}"
  end

  def name
    params.dig('channel', 'name')
  end

  def channel_arn
    params.dig('channel', 'arn')
  end

  def playback_url
    params.dig('channel', 'playback_url')
  end

  def ingest_endpoint
    params['ingest_endpoint']
  end

  def stream_key
    params['stream_key']
  end

  def get_stream
    ivs_client.get_stream(channel_arn: self.channel_arn)
  end

  def viewer_count
    self.get_stream.stream.viewer_count
  end

  private

  def ivs_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::IVS::Client.new(region: 'us-east-1', credentials: creds)
    else
      Aws::IVS::Client.new(region: 'us-east-1')
    end
  end

  def env_name_for_tag
    case
    when ENV['REVIEW_APP'] == 'true'
      'review_app'
    when ENV['S3_BUCKET'] == 'dreamkast-stg-bucket'
      'staging'
    when ENV['S3_BUCKET'] == 'dreamkast-prd-bucket'
      'production'
    else
      'others'
    end
  end

  def recording_configuration_arn
    case env_name_for_tag
    when 'production'
      'arn:aws:ivs:us-east-1:607167088920:recording-configuration/rEy1r00HJaMP'
    when 'staging'
      'arn:aws:ivs:us-east-1:607167088920:recording-configuration/VnSqwzabuOsQ'
    when 'review_app'
      'arn:aws:ivs:us-east-1:607167088920:recording-configuration/3gSuTxXYtRkg'
    when 'others'
      'arn:aws:ivs:us-east-1:607167088920:recording-configuration/3gSuTxXYtRkg'
    else
      ''
    end
  end
end
