# == Schema Information
#
# Table name: registered_talks
#
#  id         :integer          not null, primary key
#  profile_id :integer
#  talk_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
