# == Schema Information
#
# Table name: check_ins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :integer
#  profile_id :integer
#  ticket_id  :integer
#
# Indexes
#
#  index_check_ins_on_order_id    (order_id)
#  index_check_ins_on_profile_id  (profile_id)
#  index_check_ins_on_ticket_id   (ticket_id)
#
require 'rails_helper'

RSpec.describe(CheckIn, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
