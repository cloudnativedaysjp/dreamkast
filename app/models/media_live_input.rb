require 'aws-sdk-medialive'

class MediaLiveInput < ApplicationRecord
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  before_create :set_uuid

  belongs_to :media_live_input_security_group
  belongs_to :streaming
  has_one :media_live_channel

  def create_aws_resource
    unless exists_aws_resource?
      input_resp = media_live_client.create_input(create_input_params)
      update!(input_id: input_resp.input.id)
    end
  end

  def exists_aws_resource?
    media_live_client.describe_input(input_id:)
    true
  rescue Aws::MediaLive::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    if exists_aws_resource?
      media_live_client.delete_input(input_id:)
      wait_input_until(:input_deleted, input_id)
    end
  end

  def aws_resource
    @aws_resource ||= media_live_client.describe_input(input_id:) if input_id
  end

  def destination_url
    aws_resource&.destinations&.first&.url
  end

  private

  def resource_name
    conference = streaming.conference
    track = streaming.track

    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def tags
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    tags
  end

  def create_input_params
    {
      name: resource_name,
      type: 'RTMP_PUSH',
      destinations: [{ stream_name: "#{random_string}/#{random_string}" }],
      input_security_groups: [media_live_input_security_group.input_security_group_id],
      tags:
    }
  end

  def random_string
    ('a'..'z').to_a.sample(10).join
  end
end
