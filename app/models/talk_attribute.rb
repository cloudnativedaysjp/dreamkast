class TalkAttribute < ApplicationRecord
  # Associations
  has_many :talk_attribute_associations, dependent: :destroy
  has_many :talks, through: :talk_attribute_associations

  # Validations
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z_]+\z/ }
  validates :display_name, presence: true

  # Scopes
  scope :exclusive, -> { where(is_exclusive: true) }
  scope :non_exclusive, -> { where(is_exclusive: false) }
  scope :ordered, -> { order(:display_name) }

  # Class methods
  def self.keynote
    find_by!(name: 'keynote')
  end

  def self.sponsor
    find_by!(name: 'sponsor')
  end

  def self.intermission
    find_by!(name: 'intermission')
  end
end
