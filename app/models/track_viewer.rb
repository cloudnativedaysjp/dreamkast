class TrackViewer < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :dkui }
end
