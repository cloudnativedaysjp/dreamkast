FactoryBot.define do
  factory :viewer_count do
    conference_id { 1 }
    track_id { 1 }
    stream_type { "MyString" }
    talk_id { 1 }
    count { 1 }
  end
end
