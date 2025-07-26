# == Schema Information
#
# Table name: talks_speakers
#
#  id         :integer          not null, primary key
#  talk_id    :integer
#  speaker_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_talks_speakers_on_speaker_id  (speaker_id)
#

FactoryBot.define do
  factory :talks_speaker
end
