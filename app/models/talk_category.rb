class TalkCategory < ApplicationRecord
  has_one :talk
  belongs_to :conference

  enum :sub_conference_type, {
    cnd: 'cnd',
    pek: 'pek',
    srek: 'srek'
  }, prefix: true

  scope :for_cnd, -> { where(conference_id: 15, sub_conference_type: 'cnd') }
  scope :for_pek, -> { where(conference_id: 15, sub_conference_type: 'pek') }
  scope :for_srek, -> { where(conference_id: 15, sub_conference_type: 'srek') }
end
