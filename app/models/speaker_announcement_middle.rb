# == Schema Information
#
# Table name: speaker_announcement_middles
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  speaker_announcement_id :bigint           not null
#  speaker_id              :bigint           not null
#
# Indexes
#
#  index_speaker_announcement_middles_on_speaker_announcement_id  (speaker_announcement_id)
#  index_speaker_announcement_middles_on_speaker_id               (speaker_id)
#
# Foreign Keys
#
#  fk_rails_...  (speaker_announcement_id => speaker_announcements.id)
#  fk_rails_...  (speaker_id => speakers.id)
#
class SpeakerAnnouncementMiddle < ApplicationRecord
  belongs_to :speaker
  belongs_to :speaker_announcement
end
