# == Schema Information
#
# Table name: media_package_parameters
#
#  id                       :string(255)      not null, primary key
#  name                     :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  media_package_channel_id :bigint           not null
#  streaming_id             :string(255)      not null
#
# Indexes
#
#  index_media_package_parameters_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_parameters_on_streaming_id              (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
#  fk_rails_...  (streaming_id => streamings.id)
#
require 'aws-sdk-medialive'

class MediaPackageParameter < ApplicationRecord
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  before_destroy :delete_aws_resource

  before_create :set_uuid

  belongs_to :streaming
  belongs_to :media_package_channel

  def create_aws_resources
    unless exists_aws_resource?
      create_parameter("/medialive/#{resource_name}", media_package_channel.ingest_endpoint_password)
      update!(name: "/medialive/#{resource_name}")
    end
  end

  def exists_aws_resource?
    ssm_client.describe_parameters(filters: [{ key: 'Name', values: ["/medialive/#{resource_name}"] }]).parameters.any?
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    delete_parameter("/medialive/#{resource_name}") if exists_aws_resource?
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
end
