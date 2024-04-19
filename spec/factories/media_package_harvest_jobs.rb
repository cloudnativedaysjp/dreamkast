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
FactoryBot.define do
  factory :media_package_harvest_job
end
