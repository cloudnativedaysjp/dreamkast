class StampRallyCheckPoint < ApplicationRecord
  class Type < ApplicationRecord
    KLASSES = [StampRallyCheckPoint, StampRallyCheckPointBooth, StampRallyCheckPointFinish].freeze
  end
end
