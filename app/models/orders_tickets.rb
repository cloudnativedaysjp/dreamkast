# == Schema Information
#
# Table name: orders_tickets
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :bigint           not null
#  ticket_id  :bigint           not null
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
class OrdersTickets < ApplicationRecord
  belongs_to :order
  belongs_to :ticket
end
