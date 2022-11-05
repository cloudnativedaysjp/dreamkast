# == Schema Information
#
# Table name: orders
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
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
    trait :ticket_a do
      ticket :online
    end

    trait :b do
      title { 'ticket b' }
      description { 'b' }
      price { 0 }
      stock { 500 }
    end

    trait :online do
      title { 'オンライン参加' }
      description { 'online' }
      price { 0 }
      stock { 500 }
    end

    trait :offline do
      title { 'オフライン参加' }
      description { 'offline' }
      price { 0 }
      stock { 2000 }
    end
  end
end
