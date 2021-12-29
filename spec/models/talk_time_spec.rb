# == Schema Information
#
# Table name: talk_times
#
#  id            :bigint           not null, primary key
#  time_minutes  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_talk_times_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
require 'rails_helper'

RSpec.describe(TalkTime, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
