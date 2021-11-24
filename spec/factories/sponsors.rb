# == Schema Information
#
# Table name: sponsors
#
#  id             :bigint           not null, primary key
#  abbr           :string(255)
#  description    :text(65535)
#  name           :string(255)
#  speaker_emails :string(255)
#  url            :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :bigint           not null
#
# Indexes
#
#  index_sponsors_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
FactoryBot.define do
  factory :sponsor do
    id { 1 }
    conference_id { 1 }
    name { "\u30B9\u30DD\u30F3\u30B5\u30FC1\u682A\u5F0F\u4F1A\u793E" }
    abbr { "sponsor1" }
    url { "https://example.com/" }

    trait :with_speaker_emails do
      speaker_emails { "alice@example.com" }
    end
  end
end
