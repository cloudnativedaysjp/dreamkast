# == Schema Information
#
# Table name: tickets
#
#  id            :string(255)      not null, primary key
#  description   :text(65535)      not null
#  price         :integer          not null
#  stock         :integer          not null
#  title         :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_tickets_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class Ticket < ApplicationRecord
  before_create :set_uuid

  belongs_to :conference

  has_many :orders_tickets
  has_many :orders, through: :orders_tickets

  def remaining_stock
    stock - orders.includes([:cancel_order]).select { |order| order.cancel_order.nil? }.size
  end

  def stock_status
    if sold_out?
      '残席なし'
    elsif (remaining_stock.to_f / stock) < 0.2
      '残席わずか'
    else
      '残席あり'
    end
  end

  def sold_out?
    remaining_stock.zero?
  end
end
