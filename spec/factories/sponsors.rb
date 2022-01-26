# == Schema Information
#
# Table name: sponsors
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  abbr           :string(255)
#  description    :text(65535)
#  url            :string(255)
#  conference_id  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  speaker_emails :string(255)
#
# Indexes
#
#  index_sponsors_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :sponsor do
    id { 1 }
    conference_id { 1 }
    name { 'スポンサー1株式会社' }
    abbr { 'sponsor1' }
    url { 'https://example.com/' }

    trait :with_speaker_emails do
      speaker_emails { 'alice@example.com' }
    end
  end
end
