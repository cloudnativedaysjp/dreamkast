# == Schema Information
#
# Table name: live_streams
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  track_id      :integer          not null
#  type          :string(255)
#  params        :json
#
# Indexes
#
#  index_live_streams_on_conference_id  (conference_id)
#  index_live_streams_on_track_id       (track_id)
#

class LiveStream < ApplicationRecord
  belongs_to :conference
end
