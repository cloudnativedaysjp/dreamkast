# == Schema Information
#
# Table name: media_package_parameters
#
#  id                       :bigint           not null, primary key
#  name                     :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  conference_id            :bigint           not null
#  media_package_channel_id :bigint           not null
#  track_id                 :bigint           not null
#
# Indexes
#
#  index_media_package_parameters_on_conference_id             (conference_id)
#  index_media_package_parameters_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_parameters_on_track_id                  (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
#  fk_rails_...  (track_id => tracks.id)
#

require 'aws-sdk-medialive'

class MediaPackageParameter < ApplicationRecord
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track
  belongs_to :media_package_channel

  def create_aws_resources
    unless exists_aws_resource?
      create_parameter("/medialive/#{resource_name}", media_package_channel.ingest_endpoint_password)
      update!(name: "/medialive/#{resource_name}")
    end
  rescue => e
    logger.error(e.message)
  end

  def exists_aws_resource?
    ssm_client.describe_parameters(filters: [{ key: 'Name', values: ["/medialive/#{resource_name}"] }]).parameters.any?
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    delete_parameter("/medialive/#{resource_name}")
  rescue => e
    logger.error(e.message.to_s)
  end

  private

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
