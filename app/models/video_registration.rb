# == Schema Information
#
# Table name: video_registrations
#
#  id         :integer          not null, primary key
#  talk_id    :integer          not null
#  url        :string(255)
#  status     :integer          default("0"), not null
#  statistics :json             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_video_registrations_on_talk_id  (talk_id)
#

class VideoRegistration < ApplicationRecord
  belongs_to :talk
  enum status: { not_submitted: 0, submitted: 1, confirmed: 2 }
end
