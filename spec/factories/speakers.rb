FactoryBot.define do
  factory :speaker do
    sub { SecureRandom.hex(8) }
    after(:build) do |speaker|
      user = User.find_or_create_by!(sub: speaker.sub) do |u|
        u.email = speaker.email
      end
      speaker.user_id = user.id
    end

    before(:create) do |speaker|
      user = User.find_or_create_by!(sub: speaker.sub) do |u|
        u.email = speaker.email
      end
      speaker.user_id = user.id
    end
  end

  factory :speaker_alice, class: Speaker do
    id { 1 }
    sub { 'google-oauth2|alice' }
    email { 'alice@example.com' }
    name { 'Alice' }
    profile { 'This is profile' }
    company { 'company' }
    job_title { 'job_title' }
    conference_id { 1 }

    trait :with_talk1_registered do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk1, :registered)
        speaker.talks << talk
      end
    end

    trait :with_talk1_accepted do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk1, :accepted)
        speaker.talks << talk
      end
    end

    trait :with_talk1_rejected do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk1, :rejected)
        speaker.talks << talk
      end
    end

    trait :with_sponsor_session do
      after(:build) do |speaker|
        sponsor = create(:sponsor)
        talk = create(:sponsor_session, :registered, sponsor:)
        speaker.talks << talk
      end
    end

    # after(:build) do |speaker|
    #   user = User.find_or_create_by!(sub: speaker.sub) do |u|
    #     u.email = speaker.email
    #   end
    #   speaker.user_id = user.id
    # end

    # before(:create) do |speaker|
    #   user = User.find_or_create_by!(sub: speaker.sub) do |u|
    #     u.email = speaker.email
    #   end
    #   speaker.user_id = user.id
    # end
  end

  factory :talks_speakers, class: TalksSpeaker

  factory :speaker_bob, class: Speaker do
    id { 2 }
    sub { 'bbb' }
    email { 'bar@example.com' }
    name { 'Bob' }
    profile { 'This is profile' }
    company { 'company' }
    job_title { 'job_title' }
    conference_id { 1 }

    trait :with_talk2_rejected do
      after(:build) do |speaker|
        talk = FactoryBot.create(:talk2, :rejected)
        speaker.talks << talk
      end
    end

    after(:build) do |speaker|
      user = User.find_or_create_by!(sub: speaker.sub) do |u|
        u.email = speaker.email
      end
      speaker.user_id = user.id
    end

    before(:create) do |speaker|
      user = User.find_or_create_by!(sub: speaker.sub) do |u|
        u.email = speaker.email
      end
      speaker.user_id = user.id
    end
  end

  factory :speaker_mike, class: Speaker do
    id { 3 }
    sub { 'github' }
    email { 'mike@example.com' }
    name { 'Mike' }
    profile { 'This is profile' }
    company { 'company' }
    job_title { 'job_title' }
    conference_id { 1 }

    trait :with_speaker_announcement do
      id { 4 }
      after(:build) do |speaker|
        speaker_announcement = FactoryBot.create(:speaker_announcement, :published)
        speaker.speaker_announcements << speaker_announcement
        FactoryBot.create(:speaker_announcement_middle, { speaker:, speaker_announcement: })
      end
    end

    # after(:build) do |speaker|
    #   user = User.find_or_create_by!(sub: speaker.sub) do |u|
    #     u.email = speaker.email
    #   end
    #   speaker.user_id = user.id
    # end

    # before(:create) do |speaker|
    #   user = User.find_or_create_by!(sub: speaker.sub) do |u|
    #     u.email = speaker.email
    #   end
    #   speaker.user_id = user.id
    # end
  end
end
