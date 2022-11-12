# == Schema Information
#
# Table name: check_ins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :string(255)
#  profile_id :integer
#  ticket_id  :string(255)
#
# Indexes
#
#  index_check_ins_on_order_id    (order_id)
#  index_check_ins_on_profile_id  (profile_id)
#  index_check_ins_on_ticket_id   (ticket_id)
#
FactoryBot.define do
  factory :check_in, class: CheckIn do
  end
end
