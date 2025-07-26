# == Schema Information
#
# Table name: speaker_announcement_middles
#
#  id                      :integer          not null, primary key
#  speaker_id              :integer          not null
#  speaker_announcement_id :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_speaker_announcement_middles_on_speaker_announcement_id  (speaker_announcement_id)
#  index_speaker_announcement_middles_on_speaker_id               (speaker_id)
#

class SpeakerAnnouncementMiddle < ApplicationRecord
  belongs_to :speaker
  belongs_to :speaker_announcement
end
