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

class MediaLiveInputSecurityGroup < LiveStream
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track

  attr_accessor :input_security_group
  attr_accessor :input
  attr_accessor :channel

  def create_aws_resources
    unless exists_aws_resource?
      input_security_group_resp = media_live_client.create_input_security_group(create_input_security_groups_params)
      update!(input_security_group_id: input_security_group_resp.input_security_group.id)
    end
  rescue => e
    logger.error(e.message)
  end

  def exists_aws_resource?
    media_live_client.describe_input_security_group(input_security_group:)
    true
  rescue Aws::MediaLive::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    if exists_aws_resource?
      media_live_client.delete_input_security_group(input_security_group_id:)
    end
  rescue => e
    logger.error(e.message.to_s)
  end

  private

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
end
