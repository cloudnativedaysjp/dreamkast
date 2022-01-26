# == Schema Information
#
# Table name: sponsors_sponsor_types
#
#  id              :integer          not null, primary key
#  sponsor_id      :integer
#  sponsor_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe(SponsorsSponsorType, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
