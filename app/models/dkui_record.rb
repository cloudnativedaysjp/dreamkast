class DkuiRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :dkui, reading: :dkui }
end
