# == Schema Information
#
# Table name: form_items
#
#  id            :integer          not null, primary key
#  conference_id :integer
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe(FormItem, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
