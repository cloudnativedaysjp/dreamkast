# == Schema Information
#
# Table name: registered_talks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#  talk_id    :integer
#

require 'rails_helper'

RSpec.describe(RegisteredTalk, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
