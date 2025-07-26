# == Schema Information
#
# Table name: media_package_harvest_jobs
#
#  id                       :integer          not null, primary key
#  conference_id            :integer          not null
#  media_package_channel_id :integer          not null
#  talk_id                  :integer          not null
#  job_id                   :string(255)
#  status                   :string(255)
#  start_time               :datetime
#  end_time                 :datetime
#
# Indexes
#
#  index_media_package_harvest_jobs_on_conference_id             (conference_id)
#  index_media_package_harvest_jobs_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_harvest_jobs_on_talk_id                   (talk_id)
#

FactoryBot.define do
  factory :media_package_harvest_job
end
