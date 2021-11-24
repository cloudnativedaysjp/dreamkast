# == Schema Information
#
# Table name: video_registrations
#
#  id      :bigint           not null, primary key
#  status  :integer          default("not_submitted"), not null
#  url     :string(255)
#  talk_id :bigint           not null
#
# Indexes
#
#  index_video_registrations_on_talk_id  (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (talk_id => talks.id)
#
class VideoRegistration < ApplicationRecord
  belongs_to :talk
  enum status: { not_submitted: 0, submitted: 1, confirmed: 2 }
end
