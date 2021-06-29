class Proposal < ApplicationRecord
  enum status: { registered: 0, accepted: 1, rejected: 2 }

  belongs_to :talk

  def speakers
    talk.speakers
  end
end