require 'aws-sdk-medialive'

class MediaLiveInputSecurityGroup < ApplicationRecord
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  before_create :set_uuid

  belongs_to :streaming

  attr_accessor :input_security_group
  attr_accessor :input
  attr_accessor :channel

  def create_aws_resources
    unless exists_aws_resource?
      input_security_group_resp = media_live_client.create_input_security_group(create_input_security_groups_params)
      update!(input_security_group_id: input_security_group_resp.security_group.id)
    end
  rescue => e
    logger.error(e.message)
  end

  def exists_aws_resource?
    media_live_client.describe_input_security_group(input_security_group_id:)
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
