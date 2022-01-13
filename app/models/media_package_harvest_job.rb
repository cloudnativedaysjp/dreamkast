# == Schema Information
#
# Table name: media_package_harvest_jobs
#
#  id                       :bigint           not null, primary key
#  end_time                 :datetime
#  start_time               :datetime
#  conference_id            :bigint           not null
#  job_id                   :string(255)
#  media_package_channel_id :bigint           not null
#  talk_id                  :bigint
#
# Indexes
#
#  fk_rails_98wwalked                                            (talk_id)
#  index_media_package_harvest_jobs_on_conference_id             (conference_id)
#  index_media_package_harvest_jobs_on_media_package_channel_id  (media_package_channel_id)
#
# Foreign Keys
#
#  fk_rails_...        (conference_id => conferences.id)
#  fk_rails_...        (media_package_channel_id => media_package_channels.id)
#  fk_rails_98wwalked  (talk_id => talks.id)
#
require 'aws-sdk-mediapackage'

class MediaPackageHarvestJob < ApplicationRecord
  include MediaPackageHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :media_package_channel

  def job
    @job ||= media_package_client.describe_harvest_job(id: job_id)
  end

  def create_media_package_resources(start_time, end_time, origin_endpoint, s3_destination)
    resp = media_package_client.create_harvest_job(create_params(start_time, end_time, origin_endpoint, s3_destination))
    resp = media_package_client.describe_harvest_job(id: resp.id)
    update!(job_id: resp.id)
  rescue => e
    logger.error(e.message)
  end

  private

  def create_params(start_time, end_time, origin_endpoint, s3_destination)
    {
      id: "#{resource_name}_#{id}",
      start_time: start_time,
      end_time: end_time,
      origin_endpoint_id: origin_endpoint,
      s3_destination: {
        bucket_name: "dreamkast-ivs-stream-archive-dev",
        manifest_key: "mediapackage/test001/test.m3u8",
        role_arn: "arn:aws:iam::607167088920:role/MediaPackageLivetoVOD-Policy"
      }
    }
  end

  def resource_name
    track = media_package_channel.track
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
