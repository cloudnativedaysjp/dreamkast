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
  end

  factory :cndt2020_opened, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020'}
    abbr { 'cndt2020' }
    theme { 'これはTestEventAutumn2020のテーマです' }
    copyright { '© Test Event Autumn 2020 Committee' }
    privacy_policy { 'This is Privacy Policy' }
    privacy_policy_for_speaker { 'This is Privacy Policy for speaker' }
    status { 1 }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }
    about { "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
  end

  factory :cndt2020_closed, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020'}
    abbr { 'cndt2020' }
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

  factory :cndo2021, class: Conference do
    id { 2 }
    name { 'CloudNative Days Online 2021'}
    abbr { 'cndo2021' }
    theme { 'これはCloudNativeDaysOnlinee2021のテーマです' }
    copyright { '© CloudNativeDaysOnline 2021 Committee' }
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