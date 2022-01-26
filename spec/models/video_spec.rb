# == Schema Information
#
# Table name: videos
#
#  id              :integer          not null, primary key
#  talk_id         :integer
#  site            :string(255)
#  url             :string(255)
#  on_air          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  video_id        :string(255)
#  slido_id        :string(255)
#  video_file_data :text(65535)
#

require 'rails_helper'

RSpec.describe(Video, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
