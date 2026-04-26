class StampRallyCheckIn < ApplicationRecord
  include UlidPk

  belongs_to :profile
  belongs_to :stamp_rally_check_point
end
