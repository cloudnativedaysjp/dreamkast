# == Schema Information
#
# Table name: tracks
#
#  id             :integer          not null, primary key
#  number         :integer
#  name           :string(255)
#  video_id       :string(255)
#  conference_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  video_platform :string(255)
#

FactoryBot.define do
  factory :track, class: Track do
    video_platform { 'vimeo' }
  end

  factory :cndt2021_track, class: Track do
    id { 11 }
  end
end
