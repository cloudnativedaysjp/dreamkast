class RegisteredTalk < ApplicationRecord
  belongs_to :talks
  belongs_to :profiles
end
