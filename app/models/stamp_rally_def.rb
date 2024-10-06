# == Schema Information
#
# Table name: stamp_rally_defs
#
#  id            :bigint           not null, primary key
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
class StampRallyDef < ApplicationRecord
  self.inheritance_column = :type

  belongs_to :conference
  belongs_to :sponsor

  has_many :check_in_stamp_rally

  # typeが"StampRallyDefBooth"の場合にsponsor_idが必須であること
  validates :sponsor_id, presence: true, if: :stamp_rally_def_booth?

  private

  def stamp_rally_def_booth?
    type == StampRallyDefBooth.name
  end
end
