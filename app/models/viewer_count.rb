# == Schema Information
#
# Table name: viewer_counts
#
#  id            :integer          not null, primary key
#  conference_id :integer
#  track_id      :integer
#  stream_type   :string(255)
#  talk_id       :integer
#  count         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_viewer_counts_on_conference_id  (conference_id)
#  index_viewer_counts_on_talk_id        (talk_id)
#  index_viewer_counts_on_track_id       (track_id)
#

class ViewerCount < ApplicationRecord
  def self.latest_number_of_viewers
    on_air_ids = Talk.where(conference_id: Conference.opened.ids).on_air.pluck(:id)
    latest_viwer_count_ids = where(talk_id: on_air_ids).group(:talk_id).maximum(:id).values

    select(
      [:conference_id, :track_id, :talk_id, :count]
    ).where(id: latest_viwer_count_ids)
  end
end
