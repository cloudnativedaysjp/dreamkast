# == Schema Information
#
# Table name: tracks
#
#  id             :bigint           not null, primary key
#  name           :string(255)
#  number         :integer
#  video_platform :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :integer
#  room_id        :bigint           default(0)
#  video_id       :string(255)
#
# Indexes
#
#  index_tracks_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :track, class: Track do
    video_platform { 'vimeo' }

    trait :has_room do
      name { 'A' }
      room { create(:room) }
    end
  end

  factory :cndt2021_track, class: Track do
    id { 11 }
  end
end
