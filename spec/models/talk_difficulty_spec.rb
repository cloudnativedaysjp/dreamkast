# == Schema Information
#
# Table name: talk_difficulties
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#
# Indexes
#
#  index_talk_difficulties_on_conference_id  (conference_id)
#

require 'rails_helper'

RSpec.describe(TalkDifficulty, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
