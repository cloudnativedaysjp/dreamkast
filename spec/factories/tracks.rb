FactoryBot.define do
  factory :track, class: Track do
    video_platform { "vimeo" }
  end

  factory :cndt2021_track, class: Track do
    id { 11 }
  end
end