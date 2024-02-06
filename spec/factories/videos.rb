# == Schema Information
#
# Table name: videos
#
#  id              :bigint           not null, primary key
#  on_air          :boolean
#  site            :string(255)
#  url             :string(255)
#  video_file_data :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  talk_id         :integer
#  video_id        :string(255)
#

FactoryBot.define do
  factory :video do
    talk_id { 1 }
    site { 'MyString' }
    url { 'MyString' }
    on_air { false }
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
