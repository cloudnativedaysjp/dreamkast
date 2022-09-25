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

FactoryBot.define do
  factory :ticket, class: Ticket do
    trait :a do
      title { 'ticket a' }
      description { 'a' }
      price { 0 }
      stock { 1000 }
    end

    trait :b do
      title { 'ticket b' }
      description { 'b' }
      price { 0 }
      stock { 500 }
    end
  end
end
