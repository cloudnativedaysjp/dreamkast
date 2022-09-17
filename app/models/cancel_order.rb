# == Schema Information
#
# Table name: cancel_orders
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :string(255)      not null
#
# Indexes
#
#  index_cancel_orders_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class CancelOrder < ApplicationRecord
  before_create :set_uuid

  belongs_to :order
end
