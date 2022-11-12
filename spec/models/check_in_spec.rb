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
#  index_check_ins_on_profile_id  (profile_id)
#
require 'rails_helper'

RSpec.describe(CheckIn, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
