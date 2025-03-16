# == Schema Information
#
# Table name: sponsor_speaker_invite_accepts
#
#  id                        :bigint           not null, primary key
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  conference_id             :bigint           not null
#  speaker_id                :bigint           not null
#  sponsor_contact_id        :bigint           not null
#  sponsor_id                :bigint           not null
#  sponsor_speaker_invite_id :bigint           not null
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
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (speaker_id => speakers.id)
#  fk_rails_...  (sponsor_contact_id => sponsor_contacts.id)
#  fk_rails_...  (sponsor_id => sponsors.id)
#  fk_rails_...  (sponsor_speaker_invite_id => sponsor_speaker_invites.id)
#

class SponsorSpeakerInviteAccept < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  belongs_to :sponsor_contact
  belongs_to :speaker
  belongs_to :sponsor_speaker_invite, dependent: :destroy
end
