# == Schema Information
#
# Table name: videos
#
#  id              :integer          not null, primary key
#  talk_id         :integer
#  site            :string(255)
#  url             :string(255)
#  on_air          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  video_id        :string(255)
#  slido_id        :string(255)
#  video_file_data :text(65535)
#

FactoryBot.define do
  factory :video do
    talk_id { 1 }
    site { 'MyString' }
    url { 'MyString' }
    on_air { false }
    slido_id { '1234' }
    video_id { '1234' }

    trait :on_air do
      on_air { true }
    end

    trait :off_air do
      on_air { false }
    end

    trait :talk1 do
      talk_id { 1 }
    end

    trait :talk2 do
      talk_id { 2 }
    end

    trait :talk3 do
      talk_id { 3 }
    end
  end
end
