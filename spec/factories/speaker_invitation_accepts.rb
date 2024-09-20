# == Schema Information
#
# Table name: speaker_invitation_accepts
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  conference_id         :bigint           not null
#  speaker_id            :bigint           not null
#  speaker_invitation_id :bigint           not null
#  talk_id               :bigint           not null
#
# Indexes
#
#  index_speaker_invitation_accepts_on_conference_id            (conference_id)
#  index_speaker_invitation_accepts_on_conference_speaker_talk  (conference_id,speaker_id,talk_id) UNIQUE
#  index_speaker_invitation_accepts_on_speaker_id               (speaker_id)
#  index_speaker_invitation_accepts_on_speaker_invitation_id    (speaker_invitation_id)
#  index_speaker_invitation_accepts_on_talk_id                  (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (speaker_id => speakers.id)
#  fk_rails_...  (speaker_invitation_id => speaker_invitations.id)
#  fk_rails_...  (talk_id => talks.id)
#
FactoryBot.define do
  factory :speaker_invitation_accept do
    speaker_invitation { nil }
  end
end
