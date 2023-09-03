# == Schema Information
#
# Table name: media_live_inputs
#
#  id                                 :bigint           not null, primary key
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  conference_id                      :bigint           not null
#  input_id                           :string(255)
#  media_live_input_security_group_id :bigint           not null
#  track_id                           :bigint           not null
#
# Indexes
#
#  index_media_live_inputs_on_conference_id                       (conference_id)
#  index_media_live_inputs_on_media_live_input_security_group_id  (media_live_input_security_group_id)
#  index_media_live_inputs_on_track_id                            (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (media_live_input_security_group_id => media_live_input_security_groups.id)
#  fk_rails_...  (track_id => tracks.id)
#

require 'aws-sdk-medialive'

class MediaLiveInput < ApplicationRecord
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track
  belongs_to :media_live_input_security_group
  has_one :media_live_channel

  def create_aws_resource
    unless exists_aws_resource?
      input_resp = media_live_client.create_input(create_input_params(media_live_input_security_group.input_security_group_id))
      update!(input_id: input_resp.input.id)
    end
  rescue => e
    logger.error(e.message)
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
  rescue => e
    logger.error(e.message.to_s)
  end

  def aws_resource
    @aws_resource ||= media_live_client.describe_input(input_id:)
  end

  private

  def destination_base
    "s3://#{bucket_name}/medialive/#{conference.abbr}"
  end

  def bucket_name
    case env_name
    when 'production'
      'dreamkast-ivs-stream-archive-prd'
    when 'staging'
      'dreamkast-ivs-stream-archive-stg'
    else
      'dreamkast-ivs-stream-archive-dev'
    end
  end

  def cloudfront_domain_name
    case env_name
    when 'staging'
      'd3i2o0iduabu0p.cloudfront.net'
    when 'production'
      'd3pun3ptcv21q4.cloudfront.net'
    else
      'd1jzp6sbtx9by.cloudfront.net'
    end
  end

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def create_input_security_groups_params
    {
      tags:,
      whitelist_rules: [{ cidr: '0.0.0.0/0' }]
    }
  end

  def tags
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    tags
  end

  def create_input_params(input_security_group_id)
    {
      name: resource_name,
      type: 'RTMP_PUSH',
      destinations: [{ stream_name: "#{random_string}/#{random_string}" }],
      input_security_groups: [input_security_group_id],
      tags:
    }
  end

  def random_string
    ('a'..'z').to_a.sample(10).join
  end
end
