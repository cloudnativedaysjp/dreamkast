# == Schema Information
#
# Table name: stamp_rally_defs
#
#  id            :string(26)       not null, primary key
#  type          :string(255)      not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint
#
# Indexes
#
#  index_stamp_rally_defs_on_conference_id  (conference_id)
#  index_stamp_rally_defs_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class StampRallyDefFinish < StampRallyDef
end
