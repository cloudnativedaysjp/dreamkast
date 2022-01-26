# == Schema Information
#
# Table name: registered_talks
#
#  id         :integer          not null, primary key
#  profile_id :integer
#  talk_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe(RegisteredTalk, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
