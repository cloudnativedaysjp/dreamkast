class TalkType < ApplicationRecord
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
    find_by!(id: 'KeynoteSession')
  end

  def self.sponsor
    find_by!(id: 'SponsorSession')
  end

  def self.intermission
    find_by!(id: 'Intermission')
  end
end
