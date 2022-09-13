# == Schema Information
#
# Table name: orders
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :bigint           not null
#  profile_id :bigint           not null
#
# Indexes
#
#  index_orders_on_order_id    (order_id)
#  index_orders_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (profile_id => profiles.id)
#
class Order < ApplicationRecord
  belongs_to :profile
end
