# == Schema Information
#
# Table name: agreements
#
#  id           :bigint           not null, primary key
#  value        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  form_item_id :integer
#  profile_id   :integer
#
require 'rails_helper'

RSpec.describe(Agreement, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
