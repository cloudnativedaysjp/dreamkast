class TrackViewer < ApplicationRecord
  self.table_name = 'track_viewer'
  self.primary_key = nil

  connects_to database: { writing: :dkui, reading: :dkui }

  scope :for_talk_ids, ->(talk_ids) { where(talk_id: talk_ids) }
end
