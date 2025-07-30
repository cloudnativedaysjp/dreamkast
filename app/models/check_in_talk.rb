class CheckInTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
  belongs_to :scanner_profile, optional: true, class_name: 'Profile'
end
