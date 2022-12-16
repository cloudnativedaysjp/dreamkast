# == Schema Information
#
# Table name: audience_counts
#
#  id         :bigint           not null, primary key
#  min        :integer
#  sub        :string(255)
#  talk_name  :string(255)
#  track_name :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  talk_id    :integer
#
# Indexes
#
#  index_audience_counts_on_talk_id  (talk_id)
#
require 'rails_helper'

RSpec.describe(AudienceCount, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
