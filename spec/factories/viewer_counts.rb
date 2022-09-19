# == Schema Information
#
# Table name: viewer_counts
#
#  id            :bigint           not null, primary key
#  count         :integer
#  stream_type   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#  talk_id       :integer
#  track_id      :integer
#
# Indexes
#
#  index_viewer_counts_on_conference_id  (conference_id)
#  index_viewer_counts_on_talk_id        (talk_id)
#  index_viewer_counts_on_track_id       (track_id)
#

FactoryBot.define do
  factory :cndt2021_viewer_count, class: ViewerCount do
    conference_id { 4 }
    track_id { 11 }
    stream_type { 'IVS' }
    talk_id { 12 }
    count { 2 }
  end

  sequence :countup do |i|
    i
  end

  factory :viewer_count, class: ViewerCount do
    conference_id { 1 }
    track_id { 1 }
    stream_type { 'IVS' }
    talk_id { 1 }
    count { generate :countup }
    trait :talk1 do
      talk_id { 1 }
      track_id { 1 }
    end
    trait :talk3 do
      talk_id { 3 }
      track_id { 3 }
    end
  end
end
