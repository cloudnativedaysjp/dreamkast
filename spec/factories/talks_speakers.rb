# == Schema Information
#
# Table name: talks_speakers
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  speaker_id :integer
#  talk_id    :integer
#
# Indexes
#
#  index_talks_speakers_on_speaker_id  (speaker_id)
#
FactoryBot.define do
  factory :talks_speaker
end
