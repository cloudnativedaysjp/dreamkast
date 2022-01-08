# == Schema Information
#
# Table name: speaker_announcements
#
#  id            :bigint           not null, primary key
#  body          :text(65535)      not null
#  only_accepted :boolean          default(FALSE)
#  publish       :boolean          default(FALSE)
#  publish_time  :datetime         not null
#  to_all        :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_speaker_announcements_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
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
    trait :speaker_mike do
      body { 'test announcement for mike' }
      publish { true }
    end
  end
end
