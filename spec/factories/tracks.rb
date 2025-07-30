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
