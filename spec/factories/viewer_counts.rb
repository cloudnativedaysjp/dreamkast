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
