# == Schema Information
#
# Table name: check_ins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#
# Indexes
#
#  index_check_ins_on_profile_id  (profile_id)
#
require 'rails_helper'

RSpec.describe(CheckIn, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
