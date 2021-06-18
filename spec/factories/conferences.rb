FactoryBot.define do
  factory :cndt2020, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020'}
    abbr { 'cndt2020' }
    theme { 'これはTestEventAutumn2020のテーマです' }
    copyright { '© Test Event Autumn 2020 Committee' }
    privacy_policy { 'This is Privacy Policy' }
    privacy_policy_for_speaker { 'This is Privacy Policy for speaker' }
    status { 0 }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }
    about { "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
    coc { "this is coc"}

    trait :registered do
      status { 0 }
    end

    trait :opened do
      status { 1 }
    end

    trait :closed do
      status { 2 }
    end

    trait :archived do
      status { 3 }
    end

    trait :speaker_entry_enabled do
      speaker_entry { 1 }
    end

    trait :speaker_entry_disabled do
      speaker_entry { 0 }
    end

    after(:build) do |conference|
      create(:day1)
      create(:day2)
      create(:track, id: 1, number: 1, name: 'A', conference_id: conference.id, video_id: 'video_1')
      create(:track, id: 2, number: 2, name: 'B', conference_id: conference.id, video_id: 'video_2')
      create(:track, id: 3, number: 3, name: 'C', conference_id: conference.id, video_id: 'video_3')
      create(:track, id: 4, number: 4, name: 'D', conference_id: conference.id, video_id: 'video_4')
      create(:track, id: 5, number: 5, name: 'E', conference_id: conference.id, video_id: 'video_5')
      create(:track, id: 6, number: 6, name: 'F', conference_id: conference.id, video_id: 'video_6')
    end
  end

  factory :cndo2021, class: Conference do
    id { 2 }
    name { 'CloudNative Days Online 2021'}
    abbr { 'cndo2021' }
    theme { 'これはTestEventAutumn2020のテーマです' }
    copyright { '© Test Event Autumn 2020 Committee' }
    privacy_policy { 'This is Privacy Policy' }
    privacy_policy_for_speaker { 'This is Privacy Policy for speaker' }
    status { 2 }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }
    about { "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
  end
end