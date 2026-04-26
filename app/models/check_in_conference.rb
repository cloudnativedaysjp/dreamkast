class CheckInConference < ApplicationRecord
  belongs_to :conference
  belongs_to :profile
  belongs_to :scanner_profile, optional: true, class_name: 'Profile'
end
