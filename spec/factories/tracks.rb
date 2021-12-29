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
#  video_id       :string(255)
#
FactoryBot.define do
  factory :track, class: Track do
    video_platform { 'vimeo' }
  end

  factory :cndt2021_track, class: Track do
    id { 11 }
  end
end
