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

require 'aws-sdk-medialive'

class MediaLiveInput < LiveStream
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track

  attr_accessor :input_security_group
  attr_accessor :input
  attr_accessor :channel

  def initialize(input_security_group: nil)
    @input_security_group = input_security_group

    super
  end

  def create_aws_resource
    unless exists_aws_resource?
      input_resp = media_live_client.create_input(create_input_params(@input_security_group.input_security_group_id))
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
    end
  rescue => e
    logger.error(e.message.to_s)
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
