# == Schema Information
#
# Table name: stamp_rally_check_points
#
#  id            :string(26)       not null, primary key
#  conference_id :integer          not null
#  sponsor_id    :integer
#  type          :string(255)      not null
#  name          :string(255)      not null
#  description   :string(255)      not null
#  position      :integer
#
# Indexes
#
#  index_stamp_rally_check_points_on_conference_id  (conference_id)
#  index_stamp_rally_check_points_on_sponsor_id     (sponsor_id)
#

class StampRallyCheckPointFinish < StampRallyCheckPoint
end
