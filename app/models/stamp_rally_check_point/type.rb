class StampRallyCheckPoint < ApplicationRecord
  class Type < ApplicationRecord
    KLASSES = [StampRallyPointBooth, StampRallyPointFinish].freeze
  end
end
