class TalkType < ApplicationRecord
  # Constants
  SESSION_ID = 'Session'.freeze
  KEYNOTE_SESSION_ID = 'KeynoteSession'.freeze
  SPONSOR_SESSION_ID = 'SponsorSession'.freeze
  INTERMISSION_ID = 'Intermission'.freeze

  # Associations
  has_many :talk_type_associations, dependent: :destroy
  has_many :talks, through: :talk_type_associations

  # Validations
  validates :display_name, presence: true

  # Scopes
  scope :exclusive, -> { where(is_exclusive: true) }
  scope :non_exclusive, -> { where(is_exclusive: false) }
  scope :ordered, -> { order(:display_name) }

  # Class methods
  def self.keynote
    find_by!(id: KEYNOTE_SESSION_ID)
  end

  def self.sponsor
    find_by!(id: SPONSOR_SESSION_ID)
  end

  def self.intermission
    find_by!(id: INTERMISSION_ID)
  end
end
