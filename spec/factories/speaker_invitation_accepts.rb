# == Schema Information
#
# Table name: speaker_invitation_accepts
#
#  id                    :integer          not null, primary key
#  speaker_invitation_id :integer          not null
#  conference_id         :integer          not null
#  speaker_id            :integer          not null
#  talk_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_speaker_invitation_accepts_on_conference_id            (conference_id)
#  index_speaker_invitation_accepts_on_conference_speaker_talk  (conference_id,speaker_id,talk_id) UNIQUE
#  index_speaker_invitation_accepts_on_speaker_id               (speaker_id)
#  index_speaker_invitation_accepts_on_speaker_invitation_id    (speaker_invitation_id)
#  index_speaker_invitation_accepts_on_talk_id                  (talk_id)
#

FactoryBot.define do
  factory :speaker_invitation_accept do
    speaker_invitation { nil }
  end
end
