FactoryBot.define do
  factory :talk do
    title { 'Test Talk' }
    abstract { 'Test abstract' }
    start_time { '12:00' }
    end_time { '12:40' }
    association :conference
    show_on_timetable { true }
    video_published { false }
  end

  factory :talk1, class: Talk do
    id { 1 }
    title { 'talk1' }
    start_time { '12:00' }
    end_time { '12:40' }
    abstract { 'あいうえおかきくけこさしすせそ' }
    conference_id { 1 }
    conference_day_id { 1 }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 1 }
    show_on_timetable { true }
    video_published { true }
    document_url { 'http://' }
    created_at { Time.new(2022, 9, 1, 10) }

    trait :video_published do
      video_published { true }
    end

    trait :video_not_published do
      video_published { false }
    end

    trait :has_room do
      track { create(:track, :has_room) }
    end

    trait :registered do
      after(:build) do |talk|
        create(:proposal, :registered, talk:, conference_id: talk.conference_id)
      end
    end

    trait :accepted do
      after(:build) do |talk|
        create(:proposal, :accepted, talk:, conference_id: talk.conference_id)
      end
    end

    trait :rejected do
      after(:build) do |talk|
        create(:proposal, :rejected, talk:, conference_id: talk.conference_id)
      end
    end
  end

  factory :talk2, class: Talk do
    id { 2 }
    title { 'talk2' }
    start_time { '12:00' }
    end_time { '12:40' }
    conference_id { 1 }
    conference_day_id { 2 }
    abstract { 'あいうえおかきくけこ' }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 1 }
    show_on_timetable { true }
    video_published { false }

    trait :conference_day_id_1 do
      conference_day_id { 1 }
    end

    trait :registered do
      after(:build) do |talk|
        create(:proposal, :registered, talk:, conference_id: talk.conference_id)
      end
    end

    trait :accepted do
      after(:build) do |talk|
        create(:proposal, :accepted, talk:, conference_id: talk.conference_id)
      end
    end

    trait :rejected do
      after(:build) do |talk|
        create(:proposal, :rejected, talk:, conference_id: talk.conference_id)
      end
    end
  end

  factory :talk3, class: Talk do
    id { 3 }
    title { 'talk3' }
    start_time { '13:00' }
    end_time { '13:40' }
    conference_id { 1 }
    conference_day_id { 2 }
    abstract { 'track3 talk' }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 3 }
    show_on_timetable { true }
    video_published { false }

    trait :conference_day_id_1 do
      conference_day_id { 1 }
    end

    trait :registered do
      after(:build) do |talk|
        create(:proposal, :registered, talk:, conference_id: talk.conference_id)
      end
    end

    trait :accepted do
      after(:build) do |talk|
        create(:proposal, :accepted, talk:, conference_id: talk.conference_id)
      end
    end

    trait :rejected do
      after(:build) do |talk|
        create(:proposal, :rejected, talk:, conference_id: talk.conference_id)
      end
    end
  end


  factory :talk_rejekt, class: Talk do
    id { 5 }
    title { 'Rejected Talk' }
    start_time { '19:00' }
    end_time { '21:00' }
    conference_id { 1 }
    conference_day_id { 3 }
    abstract { '残念ながらRejekted' }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 1 }
    show_on_timetable { true }
  end

  factory :talk_cm, class: Talk do
    id { 4 }
    title { 'CM' }
    start_time { '10:00' }
    end_time { '11:00' }
    conference_id { 1 }
    conference_day_id { 3 }
    abstract { 'CMCMCMCMCMCM' }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    track_id { 1 }
    show_on_timetable { false }
    video_published { true }
  end

  factory :cndo_talk1, class: Talk do
    id { 10 }
    title { 'talk1' }
    start_time { '12:30' }
    end_time { '12:40' }
    abstract { 'あいうえおかきくけこさしすせそ' }
    conference_id { 2 }
    conference_day_id { 10 }
    talk_difficulty_id { 10 }
    talk_category_id { 10 }
    track_id { 10 }
    show_on_timetable { true }
    video_published { true }
    document_url { 'http://' }
  end

  factory :cndo_talk2, class: Talk do
    id { 11 }
    title { 'talk2' }
    start_time { '12:30' }
    end_time { '12:40' }
    conference_id { 2 }
    conference_day_id { 11 }
    abstract { 'あいうえおかきくけこ' }
    talk_difficulty_id { 10 }
    talk_category_id { 10 }
    track_id { 10 }
    show_on_timetable { true }
    video_published { false }
  end

  factory :cndt2021_talk1, class: Talk do
    id { 12 }
    title { 'talk1' }
    start_time { '12:30' }
    end_time { '12:40' }
    abstract { 'あいうえおかきくけこさしすせそ' }
    conference_id { 4 }
    conference_day_id { 10 }
    talk_difficulty_id { 10 }
    talk_category_id { 10 }
    track_id { 11 }
    show_on_timetable { true }
    video_published { true }
    document_url { 'http://' }
  end

  factory :sponsor_session, class: Talk do
    title { 'sponsor_session' }
    start_time { '12:30' }
    end_time { '12:40' }
    abstract { 'あいうえおかきくけこさしすせそ' }
    conference_id { 1 }
    conference_day_id { 1 }
    talk_difficulty_id { 1 }
    track_id { 1 }
    show_on_timetable { true }
    video_published { true }
    document_url { 'http://' }

    after(:create) do |talk|
      sponsor_attr = TalkAttribute.find_or_create_by!(name: 'sponsor') do |attr|
        attr.display_name = 'スポンサーセッション'
        attr.is_exclusive = false
      end
      talk.talk_attributes << sponsor_attr unless talk.talk_attributes.include?(sponsor_attr)
    end

    trait :registered do
      after(:build) do |talk|
        create(:proposal, :registered, talk:, conference_id: talk.conference_id)
      end
    end

    trait :accepted do
      after(:build) do |talk|
        create(:proposal, talk:, status: 1, conference_id: talk.conference_id)
      end
    end
  end

  factory :keynote_session, class: Talk do
    title { 'keynote_session' }
    start_time { '10:00' }
    end_time { '10:40' }
    abstract { 'キーノートセッション' }
    conference_id { 1 }
    conference_day_id { 1 }
    talk_difficulty_id { 1 }
    track_id { 1 }
    show_on_timetable { true }
    video_published { true }
    document_url { 'http://' }

    after(:create) do |talk|
      keynote_attr = TalkAttribute.find_or_create_by!(name: 'keynote') do |attr|
        attr.display_name = 'キーノート'
        attr.is_exclusive = false
      end
      talk.talk_attributes << keynote_attr unless talk.talk_attributes.include?(keynote_attr)
    end

    trait :registered do
      after(:build) do |talk|
        create(:proposal, :registered, talk:, conference_id: talk.conference_id)
      end
    end

    trait :accepted do
      after(:build) do |talk|
        create(:proposal, talk:, status: 1, conference_id: talk.conference_id)
      end
    end
  end

  factory :has_no_conference_days, class: Talk do
    id { 100 }
    title { 'not accepted talk' }
    abstract { 'あいうえおかきくけこさしすせそ' }
    conference_id { 1 }
    talk_difficulty_id { 1 }
    talk_category_id { 1 }
    show_on_timetable { false }
    video_published { false }
    document_url { 'http://' }
    created_at { Time.new(2022, 9, 1, 10) }
  end

  factory :intermission, class: Talk do
    title { 'Intermission' }
    abstract { 'intermission' }
    start_time { '12:00' }
    end_time { '12:10' }
    conference_id { 1 }
    show_on_timetable { true }
    video_published { false }

    after(:create) do |talk|
      intermission_attr = TalkAttribute.find_or_create_by!(name: 'intermission') do |attr|
        attr.display_name = '休憩'
        attr.is_exclusive = false
      end
      talk.talk_attributes << intermission_attr unless talk.talk_attributes.include?(intermission_attr)
    end
  end
end
