# == Schema Information
#
# Table name: booth_stamp_rally_defs
#
#  id            :bigint           not null, primary key
#  conference_id :bigint           not null
#  sponsor_id    :bigint           not null
#
# Indexes
#
#  index_booth_stamp_rally_defs_on_conference_id  (conference_id)
#  index_booth_stamp_rally_defs_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (sponsor_id => sponsors.id)
#
class BoothStampRallyDef < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor

  has_one :check_in_booth_stamp_rally
end
