# == Schema Information
#
# Table name: orders
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint
#
# Indexes
#
#  index_orders_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
class Order < ApplicationRecord
  before_create :set_uuid

  belongs_to :profile

  has_one :cancel_order
  has_many :orders_tickets
  has_many :tickets, through: :orders_tickets
  has_many :check_ins
end
