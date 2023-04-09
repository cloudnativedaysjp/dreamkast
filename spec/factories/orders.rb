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

FactoryBot.define do
  factory :order, class: Order do
  end
end
