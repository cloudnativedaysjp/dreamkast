# == Schema Information
#
# Table name: orders_tickets
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :string(255)      not null
#  ticket_id  :string(255)      not null
#
# Indexes
#
#  index_orders_tickets_on_order_id   (order_id)
#  index_orders_tickets_on_ticket_id  (ticket_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (ticket_id => tickets.id)
#
class OrdersTicket < ApplicationRecord
  before_create :set_uuid

  belongs_to :order
  belongs_to :ticket
end
