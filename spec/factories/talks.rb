FactoryBot.define do
  factory :talk1, class: Talk do
    id { 1 }
    title { "talk1" }
    start_time { "12:00" }
    end_time { "12:40" }
    abstract { "あいうえおかきくけこさしすせそ" }
    conference_id { 1 }
    conference_day_id { 1 }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track { 1 }
  end

  factory :talk2, class: Talk do
    id { 2 }
    title { "talk2" }
    start_time { "12:00" }
    end_time { "12:40" }
    conference_id { 1 }
    conference_day_id { 2 }
    abstract { "あいうえおかきくけこ" }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track { 1 }
  end
end