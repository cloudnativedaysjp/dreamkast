# == Schema Information
#
# Table name: audience_counts
#
#  id         :bigint           not null, primary key
#  min        :integer
#  sub        :string(255)
#  talk_name  :string(255)
#  track_name :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  talk_id    :integer
#
# Indexes
#
#  index_audience_counts_on_talk_id  (talk_id)
#
FactoryBot.define do
  factory :audience_count do
    sub { 'MyString' }
    min { 1 }
    track_name { 'MyString' }
    talk_id { 1 }
    talk_name { 'MyString' }
  end
end
