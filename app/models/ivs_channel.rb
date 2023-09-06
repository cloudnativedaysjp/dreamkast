# == Schema Information
#
# Table name: ivs_channels
#
#  id               :string(255)      not null, primary key
#  aws_channel_arn  :string(255)
#  aws_channel_name :string(255)
#  aws_stream_key   :string(255)
#  conference_id    :bigint           not null
#  streaming_id     :string(255)      not null
#  track_id         :bigint           not null
#
# Indexes
#
#  index_ivs_channel_on_aws_channel_name  (aws_channel_name) UNIQUE
#  index_ivs_channel_on_conference_id     (conference_id)
#  index_ivs_channel_on_streaming_id      (streaming_id)
#  index_ivs_channel_on_track_id          (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (streaming_id => streamings.id)
#  fk_rails_...  (track_id => tracks.id)
#

class IvsChannel < ApplicationRecord
  include EnvHelper

  before_create :set_uuid

  belongs_to :conference
  belongs_to :track
  belongs_to :streaming

  def create_aws_resource
    unless exists_aws_resource?
      resp = ivs_client.create_channel(create_channel_params)
      update!(aws_channel_name: resp.channel.name, aws_channel_arn: resp.channel.arn, aws_stream_key: resp.stream_key.value)
    end
  end

  def exists_aws_resource?
    return false unless aws_channel_arn

    ivs_client.get_channel(arn: aws_channel_arn)
    true
  rescue Aws::IVS::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    ivs_client.delete_channel(arn: aws_channel_arn) if exists_aws_resource?
  end

  def aws_resource
    ivs_client.get_channel(arn: aws_channel_arn)
  end

  def ingest_endpoint
    aws_resource.channel.ingest_endpoint
  end

  def get_stream
    ivs_client.get_stream(channel_arn:)
  end

  def viewer_count
    get_stream.stream.viewer_count
  end

  def ingest_endpoint_url
    "rtmps://#{ingest_endpoint}:443/app/#{aws_stream_key}"
  end

  private

  def create_channel_params
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    {
      name: channel_name,
      latency_mode: 'LOW',
      type: 'STANDARD',
      authorized: false,
      recording_configuration_arn:,
      tags:
    }
  end

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
