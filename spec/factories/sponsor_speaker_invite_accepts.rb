# == Schema Information
#
# Table name: sponsor_speaker_invite_accepts
#
#  id                        :integer          not null, primary key
#  sponsor_speaker_invite_id :integer          not null
#  conference_id             :integer          not null
#  sponsor_id                :integer          not null
#  sponsor_contact_id        :integer          not null
#  speaker_id                :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  idx_spk_inv_accepts_on_conf_spsr_speaker_contact            (conference_id,sponsor_id,speaker_id,sponsor_contact_id) UNIQUE
#  idx_spk_inv_accepts_on_invite                               (sponsor_speaker_invite_id)
#  index_sponsor_speaker_invite_accepts_on_conference_id       (conference_id)
#  index_sponsor_speaker_invite_accepts_on_speaker_id          (speaker_id)
#  index_sponsor_speaker_invite_accepts_on_sponsor_contact_id  (sponsor_contact_id)
#  index_sponsor_speaker_invite_accepts_on_sponsor_id          (sponsor_id)
#

FactoryBot.define do
  factory :sponsor_speaker_invite_accept do
    conference
    sponsor
    sponsor_contact
    speaker
    sponsor_speaker_invite
  end
end
