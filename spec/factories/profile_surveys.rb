# == Schema Information
#
# Table name: profile_surveys
#
#  id         :bigint           not null, primary key
#  department :string(255)
#  filled_at  :datetime
#  generation :string(255)
#  industry   :string(255)
#  occupation :string(255)
#  position   :string(255)
#  sub        :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :profile_survey do
    sub { 'MyString' }
    filled_at { '2022-11-28 00:12:00' }
    url { 'MyString' }
    generation { 'MyString' }
    industry { 'MyString' }
    department { 'MyString' }
    occupation { 'MyString' }
    position { 'MyString' }
  end
end
