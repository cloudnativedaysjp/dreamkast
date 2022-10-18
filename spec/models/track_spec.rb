# == Schema Information
#
# Table name: tracks
#
#  id             :bigint           not null, primary key
#  name           :string(255)
#  number         :integer
#  video_platform :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :integer
#  room_id        :bigint           default(0), not null
#  video_id       :string(255)
#

require 'rails_helper'

RSpec.describe(Track, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
