# == Schema Information
#
# Table name: registered_talks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#  talk_id    :integer
#
class RegisteredTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
  validates :profile_id, uniqueness: { scope: :talk_id }
end
