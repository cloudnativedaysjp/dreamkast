require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorSpeakersController, type: :request) do
  describe 'DELETE #destroy のセマンティクス' do
    let!(:conference) { create(:cndt2020, :registered) }
    let!(:sponsor) { create(:sponsor, conference:) }
    let!(:sponsor_contact) { create(:sponsor_alice, conference:, sponsor:) }
    let(:speaker_attrs) { { conference:, name: 'n', profile: 'p', company: 'c', job_title: 'j' } }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                   {
                                                                     info: { email: sponsor_contact.email, name: sponsor_contact.name },
                                                                     extra: { raw_info: { sub: sponsor_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                   }
                                                                 ))
    end

    context 'sponsor_id で紐付く Speaker の場合（legacy）' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor:) }

      it 'Speaker 本体は削除されず、sponsor_id が nil にクリアされる' do
        delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor.id, id: speaker.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(Speaker.exists?(speaker.id)).to(be(true))
        expect(speaker.reload.sponsor_id).to(be_nil)
        expect(sponsor.speakers).not_to(include(speaker))
      end
    end

    context 'SponsorSpeakerInviteAccept 経由で紐付く Speaker の場合（既存プロポーザル由来）' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor: nil) }
      let!(:invite) { create(:sponsor_speaker_invite, conference:, sponsor:) }
      let!(:invite_accept) do
        create(:sponsor_speaker_invite_accept,
               conference:, sponsor:, sponsor_contact:, speaker:, sponsor_speaker_invite: invite)
      end

      it 'Speaker 本体は削除されず、invite_accept のみ削除される' do
        delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor.id, id: speaker.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(Speaker.exists?(speaker.id)).to(be(true))
        expect(SponsorSpeakerInviteAccept.exists?(invite_accept.id)).to(be(false))
        expect(sponsor.speakers).not_to(include(speaker))
      end
    end

    context '通常プロポーザルの Talk を持つ Speaker の場合' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor:) }
      let!(:talk) { create(:talk1) }

      before { speaker.talks << talk }

      it 'Speaker 本体も Talk も削除されず、sponsor_id が nil にクリアされる' do
        delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor.id, id: speaker.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(Speaker.exists?(speaker.id)).to(be(true))
        expect(Talk.exists?(talk.id)).to(be(true))
        expect(speaker.reload.sponsor_id).to(be_nil)
      end
    end
  end
end
