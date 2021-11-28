# == Schema Information
#
# Table name: talk_difficulties
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#
class TalkDifficulty < ApplicationRecord
  has_one :talk
end
