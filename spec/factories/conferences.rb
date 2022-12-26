# == Schema Information
#
# Table name: conferences
#
#  id                         :bigint           not null, primary key
#  abbr                       :string(255)
#  about                      :text(65535)
#  attendee_entry             :integer
#  brief                      :string(255)
#  cfp_result_visible         :boolean          default(FALSE)
#  coc                        :text(65535)
#  committee_name             :string(255)      default("CloudNative Days Committee"), not null
#  conference_status          :string(255)      default(NULL)
#  copyright                  :string(255)
#  name                       :string(255)
#  privacy_policy             :text(65535)
#  privacy_policy_for_speaker :text(65535)
#  show_sponsors              :boolean          default(FALSE)
#  show_timetable             :integer
#  speaker_entry              :integer
#  status                     :integer          default(0), not null
#  theme                      :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_conferences_on_status  (status)
#

FactoryBot.define do
  factory :cndt2020, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020' }
    abbr { 'cndt2020' }
    theme { "\u3053\u308C\u306FTestEventAutumn2020\u306E\u30C6\u30FC\u30DE\u3067\u3059" }
    copyright { "\u00A9 Test Event Autumn 2020 Committee" }
    privacy_policy { 'This is Privacy Policy' }
    privacy_policy_for_speaker { 'This is Privacy Policy for speaker' }
    status { 0 }
    conference_status { Conference::StATUS_REGISTERED }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }
    committee_name { 'CloudNative Days Tokyo 2020 Committee' }
    about do
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end
    coc { 'this is coc' }

    trait :registered do
      status { 0 }
      conference_status { Conference::STATUS_REGISTERED }
    end

    trait :opened do
      status { 1 }
      conference_status { Conference::STATUS_OPENED }
      speaker_entry { 0 } # Generally, speaker_entry should be disabled while conference is opened
    end

    trait :closed do
      status { 2 }
      conference_status { Conference::STATUS_CLOSED }
      speaker_entry { 0 }
    end

    trait :archived do
      status { 3 }
      conference_status { Conference::STATUS_ARCHIVED }
      speaker_entry { 0 }
    end

    trait :speaker_entry_enabled do
      speaker_entry { 1 }
    end

    trait :speaker_entry_disabled do
      speaker_entry { 0 }
    end

    trait :cfp_result_visible do
      cfp_result_visible { true }
    end

    trait :cfp_result_invisible do
      cfp_result_visible { false }
    end

    after(:build) do |conference|
      create(:day1, conference:)
      create(:day2, conference:)
      create(:track, id: 1, number: 1, name: 'A', conference_id: conference.id, video_id: 'video_1')
      create(:track, id: 2, number: 2, name: 'B', conference_id: conference.id, video_id: 'video_2')
      create(:track, id: 3, number: 3, name: 'C', conference_id: conference.id, video_id: 'video_3')
      create(:track, id: 4, number: 4, name: 'D', conference_id: conference.id, video_id: 'video_4')
      create(:track, id: 5, number: 5, name: 'E', conference_id: conference.id, video_id: 'video_5')
      create(:track, id: 6, number: 6, name: 'F', conference_id: conference.id, video_id: 'video_6')
      create(:ticket, :a, conference:)
      create(:ticket, :b, conference:)
    end
  end

  factory :cndo2021, class: Conference do
    id { 2 }
    name { 'CloudNative Days Online 2021' }
    abbr { 'cndo2021' }
    theme { "\u3053\u308C\u306FTestEventAutumn2020\u306E\u30C6\u30FC\u30DE\u3067\u3059" }
    copyright { "\u00A9 Test Event Autumn 2020 Committee" }
    privacy_policy { 'This is Privacy Policy' }
    privacy_policy_for_speaker { 'This is Privacy Policy for speaker' }
    status { 2 }
    conference_status { Conference::SATUS_CLOSED }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }
    committee_name { 'CloudNative Days Spring 2021 ONLINE Committee' }
    coc { 'this is coc' }

    about do
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end

    after(:build) do |conference|
      create(:cndo_day1, conference:)
      create(:cndo_day2, conference:)
      create(:track, id: 10, number: 1, name: 'A', conference_id: conference.id, video_id: 'video_7')
      create(:track, id: 11, number: 2, name: 'B', conference_id: conference.id, video_id: 'video_7')
      create(:track, id: 12, number: 3, name: 'C', conference_id: conference.id, video_id: 'video_7')
      create(:track, id: 13, number: 4, name: 'D', conference_id: conference.id, video_id: 'video_7')
      create(:track, id: 14, number: 5, name: 'E', conference_id: conference.id, video_id: 'video_7')
      create(:track, id: 15, number: 6, name: 'F', conference_id: conference.id, video_id: 'video_7')
      create(:track, id: 16, number: 7, name: 'G', conference_id: conference.id, video_id: 'video_7')
      create(:ticket, :a, conference:)
      create(:ticket, :b, conference:)
    end
  end

  factory :one_day, class: Conference do
    name { 'One Day Conference' }
    abbr { 'oneday' }
    status { 2 }
    conference_status { Conference::STATUS_CLOSED }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }

    after(:create) do |conference|
      create(:one_day1, conference:)
      create(:internal, conference:)
    end
  end

  factory :two_day, class: Conference do
    name { 'Two Day Conference' }
    abbr { 'twoday' }
    status { 2 }
    conference_status { Conference::STATUS_CLOSED }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }

    after(:create) do |conference|
      create(:two_day1, conference:)
      create(:two_day2, conference:)
      create(:internal, conference:)
    end
  end

  factory :cndt2021, class: Conference do
    id { 4 }
    name { 'CloudNative Days Tokyo 2021' }
    abbr { 'cndt2021' }
    theme { "\u3053\u308C\u306FTestEventAutumn2021\u306E\u30C6\u30FC\u30DE\u3067\u3059" }
    copyright { "\u00A9 Test Event Autumn 2021 Committee" }
    privacy_policy { 'This is Privacy Policy' }
    privacy_policy_for_speaker { 'This is Privacy Policy for speaker' }
    status { 2 }
    conference_status { Conference::STATUS_CLOSED }
    speaker_entry { 1 }
    attendee_entry { 1 }
    show_timetable { 1 }
    committee_name { 'CloudNative Days Tokyo 2020 Committee' }
    about do
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end

    after(:build) do |conference|
      create(:cndt2021_day1, conference:)
      create(:cndt2021_day2, conference:)
    end
  end
end
