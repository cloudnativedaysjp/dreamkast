class TalkCategory < ApplicationRecord
  has_one :talk
  belongs_to :conference

  enum :sub_conference_type, {
    cnd: 'cnd',
    pek: 'pek',
    srek: 'srek'
  }, prefix: true
end
