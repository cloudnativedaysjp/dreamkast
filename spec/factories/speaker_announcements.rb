# == Schema Information
#
# Table name: speaker_announcements
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  publish_time  :datetime         not null
#  body          :text(65535)      not null
#  publish       :boolean          default("0")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  receiver      :integer          default("0"), not null
#
# Indexes
#
#  index_speaker_announcements_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :speaker_announcement do
    conference_id { 1 }
    publish_time { Time.now }
    body { 'test announcement for alice' }
    publish { false }
    trait :published do
      publish { true }
    end
    trait :published_all do
      body { 'test announcement for all speaker' }
      receiver { :all_speaker }
      publish { true }
    end
    trait :only_accepted do
      body { 'test announcement for only accepted' }
      receiver { :only_accepted }
      publish { true }
    end
    trait :speaker_mike do
      body { 'test announcement for mike' }
      publish { true }
    end
  end
end
