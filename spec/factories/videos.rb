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
#  slido_id        :string(255)
#  talk_id         :integer
#  video_id        :string(255)
#
FactoryBot.define do
  factory :video do
    talk_id { 1 }
    site { 'MyString' }
    url { 'MyString' }
    on_air { false }
    slido_id { '1234' }
    video_id { '1234' }
  end
end
