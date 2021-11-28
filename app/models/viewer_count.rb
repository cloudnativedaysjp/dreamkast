# == Schema Information
#
# Table name: viewer_counts
#
#  id            :bigint           not null, primary key
#  count         :integer
#  stream_type   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#  talk_id       :integer
#  track_id      :integer
#
# Indexes
#
#  index_viewer_counts_on_conference_id  (conference_id)
#  index_viewer_counts_on_talk_id        (talk_id)
#  index_viewer_counts_on_track_id       (track_id)
#
class ViewerCount < ApplicationRecord
end
