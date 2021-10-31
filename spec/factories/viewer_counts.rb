FactoryBot.define do
  factory :cndt2021_viewer_count, class: ViewerCount do
    conference_id { 4 }
    track_id { 11 }
    stream_type { "IVS" }
    talk_id { 12 }
    count { 2 }
  end
end
