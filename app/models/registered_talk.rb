class RegisteredTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
  validates :profile_id,  uniqueness: { scope: :talk_id }
end
