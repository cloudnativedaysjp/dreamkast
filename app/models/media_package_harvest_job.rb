# == Schema Information
#
# Table name: media_package_harvest_jobs
#
#  id                       :bigint           not null, primary key
#  end_time                 :datetime
#  start_time               :datetime
#  status                   :string(255)
#  conference_id            :bigint           not null
#  job_id                   :string(255)
#  media_package_channel_id :bigint           not null
#  talk_id                  :bigint           not null
#
# Indexes
#
#  index_media_package_harvest_jobs_on_conference_id             (conference_id)
#  index_media_package_harvest_jobs_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_harvest_jobs_on_talk_id                   (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
#  fk_rails_...  (talk_id => talks.id)
#
class MediaPackageHarvestJob < ApplicationRecord
  include MediaPackageHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :media_package_channel
  belongs_to :talk

  def job
    @job ||= media_package_client.describe_harvest_job(id: job_id) if job_id
  end

  def create_media_package_resources
    resp = media_package_client.create_harvest_job(create_params)
    resp = media_package_client.describe_harvest_job(id: resp.id)
    update!(job_id: resp.id, status: resp.status)
  rescue => e
    logger.error(e.message)
  end

  private

  def create_params
    {
      id: "#{resource_name}_#{id}",
      start_time: start_time.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      end_time: end_time.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      origin_endpoint_id: resource_name,
      s3_destination: {
        bucket_name: bucket_name,
        manifest_key: manifest_key,
        role_arn: 'arn:aws:iam::607167088920:role/MediaPackageLivetoVOD-Policy'
      }
    }
  end

  def manifest_key
    "mediapackage/#{conference.abbr}/talks/#{talk_id}/playlist.m3u8"
  end

  def resource_name
    track = media_package_channel.track
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
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
end
