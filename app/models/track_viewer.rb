class TrackViewer < DkuiRecord
  self.table_name = 'track_viewer'
  self.primary_key = nil

  scope :for_talk_ids, ->(talk_ids) { where(talk_id: talk_ids) }
end
