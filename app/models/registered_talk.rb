# == Schema Information
#
# Table name: registered_talks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#  talk_id    :integer
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
