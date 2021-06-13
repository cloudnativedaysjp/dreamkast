class Proposal < ApplicationRecord
  enum status: { registered: 0, accepted: 1, rejected: 2 }

  belongs_to :talk
  has_many :proposals_speakers
  has_many :speakers, through: :proposals_speakers
end