# == Schema Information
#
# Table name: speakers
#
#  id                   :bigint           not null, primary key
#  additional_documents :text(65535)
#  avatar_data          :text(65535)
#  company              :string(255)
#  email                :text(65535)
#  job_title            :string(255)
#  name                 :string(255)
#  name_mother_tongue   :string(255)
#  profile              :text(65535)
#  sub                  :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  conference_id        :integer
#  github_id            :string(255)
#  twitter_id           :string(255)
#
FactoryBot.define do
  factory :speaker_alice, class: Speaker do
    id { 1 }
    sub { "aaa" }
    email { "alice@example.com" }
    name { "Alice" }
    profile { "This is profile" }
    company { "company" }
    job_title { "job_title" }
    conference_id { 1 }

    trait :with_talk1_registered do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk1)
        speaker.talks << talk
        FactoryBot.create(:talks_speakers, { talk: talk, speaker: speaker })
        proposal = FactoryBot.create(:proposal, :with_cndt2021, talk: talk, status: 0)
      end
    end

    trait :with_talk1_accepted do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk1)
        speaker.talks << talk
        FactoryBot.create(:talks_speakers, { talk: talk, speaker: speaker })
        proposal = FactoryBot.create(:proposal, :with_cndt2021, talk: talk, status: 1)
      end
    end

    trait :with_talk1_rejected do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk1)
        speaker.talks << talk
        FactoryBot.create(:talks_speakers, { talk: talk, speaker: speaker })
        proposal = FactoryBot.create(:proposal, :with_cndt2021, talk: talk, status: 2)
      end
    end
  end

  factory :talks_speakers, class: TalksSpeaker

  factory :speaker_bob, class: Speaker do
    id { 2 }
    sub { "bbb" }
    email { "bar@example.com" }
    name { "Bob" }
    profile { "This is profile" }
    company { "company" }
    job_title { "job_title" }
    conference_id { 1 }
  end
end
