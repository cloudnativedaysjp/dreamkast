# == Schema Information
#
# Table name: registered_talks
#
#  id         :integer          not null, primary key
#  profile_id :integer
#  talk_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RegisteredTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
  validates :profile_id, uniqueness: { scope: :talk_id }
end
