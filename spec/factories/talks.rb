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
    track_id { 1 }
    show_on_timetable { true }
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
    track_id { 1 }
    show_on_timetable { true }
  end

  factory :talk_rejekt, class: Talk do
    id { 3 }
    title { "Rejected Talk" }
    start_time { "19:00" }
    end_time { "21:00" }
    conference_id { 1 }
    conference_day_id { 3 }
    abstract { "残念ながらRejekted" }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 1 }
    show_on_timetable { true }
  end

  factory :talk_cm, class: Talk do
    id { 4 }
    title { "CM" }
    start_time { "10:00" }
    end_time { "11:00" }
    conference_id { 1 }
    conference_day_id { 3 }
    abstract { "CMCMCMCMCMCM" }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 1 }
    show_on_timetable { false }
  end
end