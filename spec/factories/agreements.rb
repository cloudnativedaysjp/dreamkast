# == Schema Information
#
# Table name: agreements
#
#  id           :integer          not null, primary key
#  profile_id   :integer
#  form_item_id :integer
#  value        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :agreement, class: Agreement
end
