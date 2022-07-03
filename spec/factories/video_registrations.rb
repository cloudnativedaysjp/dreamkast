# == Schema Information
#
# Table name: video_registrations
#
#  id         :integer          not null, primary key
#  talk_id    :integer          not null
#  url        :string(255)
#  status     :integer          default("0"), not null
#  statistics :json             not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_video_registrations_on_talk_id  (talk_id)
#

FactoryBot.define do
  factory :video_registration do
    id { 1 }
    talk_id { 1 }
    url { 'https://uploader' }
    status { 0 }
    statistics {
      JSON.parse(<<~'STATS'
        {
          "file_name": "XX",
          "resolution_status": "OK",
          "resolution_type": "FHD",
          "aspect_status": "OK",
          "aspect_ratio": "16:9",
          "duration_status": "OK",
          "duration_description": "Appropriate media duration.",
          "size_status": "OK",
          "size_description": "Appropriate media size."
        }
      STATS
                ).to_json
    }
    trait :not_submitted do
      status { 0 }
    end
    trait :submitted do
      status { 1 }
    end
    trait :confirmed do
      status { 2 }
    end
    trait :invalid_format do
      status { 3 }
    end
  end
end
