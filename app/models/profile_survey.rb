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
class ProfileSurvey < ApplicationRecord
  belongs_to :profile, class_name: 'Profile', foreign_key: 'sub', primary_key: 'sub'
end
