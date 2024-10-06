class StampRallyDef < ApplicationRecord
  class Type < ApplicationRecord
    KLASSES = [StampRallyDefBooth, StampRallyDefFinish].freeze
  end
end
