class ViewerCount < ApplicationRecord
  def self.latest_number_of_viewers
    on_air_ids = Talk.where(conference_id: Conference.opened.ids).on_air.pluck(:id)
    latest_viwer_count_ids = where(talk_id: on_air_ids).group(:talk_id).maximum(:id).values

    select(
      [:conference_id, :track_id, :talk_id, :count]
    ).where(id: latest_viwer_count_ids)
  end
end
