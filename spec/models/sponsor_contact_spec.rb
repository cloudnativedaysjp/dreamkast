require 'rails_helper'

RSpec.describe(SponsorContact, type: :model) do
  describe '#destroy' do
    let!(:conference) { create(:cndt2020, :registered) }
    let!(:sponsor) { create(:sponsor, conference:) }
    let!(:sponsor_contact) { create(:sponsor_contact, conference:, sponsor:) }

    context '紐づく SponsorSpeakerInviteAccept が存在する場合' do
      let!(:speaker) do
        create(:speaker, conference:, name: 'Invited', profile: 'p', company: 'c', job_title: 'j')
      end
      let!(:sponsor_speaker_invite) { create(:sponsor_speaker_invite, conference:, sponsor:) }
      let!(:sponsor_speaker_invite_accept) do
        create(:sponsor_speaker_invite_accept,
               conference:,
               sponsor:,
               sponsor_contact:,
               speaker:,
               sponsor_speaker_invite:)
      end

      it 'FK制約違反で落ちずに削除できる' do
        expect { sponsor_contact.destroy }.not_to(raise_error)
        expect(SponsorContact.exists?(sponsor_contact.id)).to(be(false))
      end

      it '紐づく SponsorSpeakerInviteAccept も一緒に削除される' do
        expect { sponsor_contact.destroy }.to(change(SponsorSpeakerInviteAccept, :count).by(-1))
      end
    end
  end
end
