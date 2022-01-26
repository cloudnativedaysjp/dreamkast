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

require 'rails_helper'

RSpec.describe(Agreement, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
