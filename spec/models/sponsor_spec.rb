require 'rails_helper'

RSpec.describe(Sponsor, type: :model) do
  describe '#speakers' do
    let!(:conference) { create(:cndt2020, :registered) }
    let!(:sponsor) { create(:sponsor, conference:) }
    let(:speaker_attrs) { { conference:, name: 'n', profile: 'p', company: 'c', job_title: 'j' } }

    context 'Speaker が sponsor_id で紐付いている場合（互換性維持）' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor:) }

      it '@sponsor.speakers に含まれる' do
        expect(sponsor.speakers).to(include(speaker))
      end
    end

    context 'Speaker が SponsorSpeakerInviteAccept のみで紐付いている場合（既存プロポーザル由来など）' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor: nil) }
      let!(:sponsor_contact) { create(:sponsor_contact, conference:, sponsor:) }
      let!(:invite) { create(:sponsor_speaker_invite, conference:, sponsor:) }
      let!(:invite_accept) do
        create(:sponsor_speaker_invite_accept,
               conference:, sponsor:, sponsor_contact:, speaker:, sponsor_speaker_invite: invite)
      end

      it '@sponsor.speakers に含まれる' do
        expect(sponsor.speakers).to(include(speaker))
      end
    end

    context 'Speaker が sponsor_id と SponsorSpeakerInviteAccept の両方で紐付いている場合' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor:) }
      let!(:sponsor_contact) { create(:sponsor_contact, conference:, sponsor:) }
      let!(:invite) { create(:sponsor_speaker_invite, conference:, sponsor:) }
      let!(:invite_accept) do
        create(:sponsor_speaker_invite_accept,
               conference:, sponsor:, sponsor_contact:, speaker:, sponsor_speaker_invite: invite)
      end

      it '@sponsor.speakers に重複せず1件だけ含まれる' do
        expect(sponsor.speakers.where(id: speaker.id).count).to(eq(1))
      end
    end

    context '別スポンサーの Speaker は含まれない' do
      let!(:other_sponsor) { create(:sponsor, conference:, id: 2, abbr: 'sponsor2') }
      let!(:other_speaker) { create(:speaker, **speaker_attrs, sponsor: other_sponsor) }

      it '@sponsor.speakers に含まれない' do
        expect(sponsor.speakers).not_to(include(other_speaker))
      end
    end
  end
end
