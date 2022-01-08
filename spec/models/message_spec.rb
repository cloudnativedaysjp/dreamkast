# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  content    :string(255)
#  text       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe(Message, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
