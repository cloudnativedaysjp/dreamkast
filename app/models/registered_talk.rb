class RegisteredTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
  validates :profile_id, uniqueness: { scope: :talk_id }
  after_create :add_acquired_seats
  before_destroy :reduce_acquired_seats

  def add_acquired_seats
    if profile.attend_offline?
      talk.acquired_seats = talk.acquired_seats + 1
      talk.save!
    end
  end

  def reduce_acquired_seats
    if profile.attend_offline?
      talk.acquired_seats = talk.acquired_seats - 1
      talk.save!
    end
  end
end
