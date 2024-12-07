# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string(255)
#  sub           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_users_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class User < ApplicationRecord
  belongs_to :conference
  has_one :profile

  validates :sub, presence: true, length: { maximum: 250 }
  validates :email, presence: true, email: true
end
