# == Schema Information
#
# Table name: tracks
#
#  id             :integer          not null, primary key
#  number         :integer
#  name           :string(255)
#  video_id       :string(255)
#  conference_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  video_platform :string(255)
#

require 'rails_helper'

RSpec.describe(Track, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
