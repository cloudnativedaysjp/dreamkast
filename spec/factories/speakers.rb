FactoryBot.define do
  factory :speaker do
    after(:build) do |speaker|
      next if speaker.user_id.present?
      next unless speaker.sub.present? || speaker.email.present?

      if speaker.sub.present?
        user = User.find_or_create_by!(sub: speaker.sub) do |u|
          u.email = speaker.email || "#{speaker.sub}@example.com"
        end
        speaker.user_id = user.id
      elsif speaker.email.present?
        temp_sub = "temp_#{SecureRandom.hex(8)}"
        user = User.find_or_create_by!(email: speaker.email) do |u|
          u.sub = temp_sub
        end
        speaker.user_id = user.id
      end
    end

    before(:create) do |speaker|
      next if speaker.user_id.present?
      next unless speaker.sub.present? || speaker.email.present?

      if speaker.sub.present?
        user = User.find_or_create_by!(sub: speaker.sub) do |u|
          u.email = speaker.email || "#{speaker.sub}@example.com"
        end
        speaker.user_id = user.id
      elsif speaker.email.present?
        temp_sub = "temp_#{SecureRandom.hex(8)}"
        user = User.find_or_create_by!(email: speaker.email) do |u|
          u.sub = temp_sub
        end
        speaker.user_id = user.id
      end
    end
  end

  factory :speaker_alice, class: Speaker do
    id { 1 }
    sub { 'aaa' }
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
end
