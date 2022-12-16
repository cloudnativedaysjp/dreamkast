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
require 'rails_helper'

RSpec.describe(ProfileSurvey, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
