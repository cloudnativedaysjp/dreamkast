# == Schema Information
#
# Table name: media_package_harvest_jobs
#
#  id                       :bigint           not null, primary key
#  conference_id            :bigint           not null
#  job_id                   :string(255)
#  media_package_channel_id :bigint           not null
#
# Indexes
#
#  index_media_package_harvest_jobs_on_conference_id             (conference_id)
#  index_media_package_harvest_jobs_on_media_package_channel_id  (media_package_channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
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

  def create_media_package_resources
    resp = media_package_client.create_harvest_job(create_params)
    resp = media_package_client.describe_harvest_job(id: resp.id)
    update!(job_id: resp.id)
  rescue => e
    logger.error(e.message)
  end

  private

  def create_params
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    {
      id: resource_name,
      description: '',
      tags: tags
    }
  end

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
