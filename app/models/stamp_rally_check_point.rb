# == Schema Information
#
# Table name: stamp_rally_check_points
#
#  id            :string(26)       not null, primary key
#  type          :string(255)      not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint
#
# Indexes
#
#  index_stamp_rally_check_points_on_conference_id  (conference_id)
#  index_stamp_rally_check_points_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class StampRallyCheckPoint < ApplicationRecord
  include UlidPk

  self.inheritance_column = :type

  belongs_to :conference
  belongs_to :sponsor, optional: true

  # typeが"StampRallyDefBooth"の場合にsponsor_idが必須であること
  validates :sponsor_id, presence: true, if: :stamp_rally_check_point_booth?
  # typeが"StampRallyCheckPointFinish"のレコードはカンファレンス内で1つしか作成できない
  validate :check_point_finish_is_unique_in_conference

  private

  def stamp_rally_check_point_booth?
    type == StampRallyCheckPointBooth.name
  end

  def check_point_finish_is_unique_in_conference
    if type == StampRallyCheckPointFinish.name && StampRallyCheckPoint.where(conference_id:, type: StampRallyCheckPointFinish.name).exists?
      errors.add(:type, 'StampRallyCheckPointFinishは1つのカンファレンス内で複数作成できません')
    end
  end
end
