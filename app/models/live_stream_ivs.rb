# == Schema Information
#
# Table name: live_streams
#
#  id            :bigint           not null, primary key
#  params        :json
#  type          :string(255)
#  conference_id :bigint           not null
#  track_id      :bigint           not null
#
# Indexes
#
#  index_live_streams_on_conference_id  (conference_id)
#  index_live_streams_on_track_id       (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

class LiveStreamIvs < LiveStream
  include EnvHelper

  belongs_to :conference
  belongs_to :track

  before_create do
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    resp = ivs_client.create_channel(
      name: channel_name,
      latency_mode: 'LOW',
      type: 'STANDARD',
      authorized: false,
      recording_configuration_arn:,
      tags:
    )

    self.params = {
      channel: resp.channel,
      stream_key: resp.stream_key
    }
  rescue => e
    logger.error(e.message)
  end

  before_destroy do
    ivs_client.delete_channel(arn: channel_arn) if channel_arn
  rescue Aws::IVS::Errors::ResourceNotFoundException => e
    logger.error("IVS Resource Not Found: #{e.message}")
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
    params.dig('channel', 'ingest_endpoint')
  end

  def stream_key
    params['stream_key']
  end

  def get_stream
    ivs_client.get_stream(channel_arn:)
  end

  def viewer_count
    get_stream.stream.viewer_count
  end

  def ingest_url
    "rtmps://#{ingest_endpoint}:443/app/#{params.dig('stream_key', 'value')}"
  end

  private

  def channel_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def ivs_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::IVS::Client.new(region: AWS_LIVE_STREAM_REGION, credentials: creds)
    else
      Aws::IVS::Client.new(region: AWS_LIVE_STREAM_REGION)
    end
  end

  def recording_configuration_arn
    case env_name
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
