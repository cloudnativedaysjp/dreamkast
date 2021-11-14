# == Schema Information
#
# Table name: sponsors_sponsor_types
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sponsor_id      :integer
#  sponsor_type_id :integer
#
require "rails_helper"

RSpec.describe(SponsorsSponsorType, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
