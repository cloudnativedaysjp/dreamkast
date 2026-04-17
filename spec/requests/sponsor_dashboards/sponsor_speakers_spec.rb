require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorSpeakersController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor_a) { create(:sponsor, id: 1, conference:, abbr: 'sponsor_a') }
  let!(:sponsor_b) { create(:sponsor, id: 2, conference:, abbr: 'sponsor_b') }
  let!(:sponsor_a_contact) { create(:sponsor_alice, conference:, sponsor: sponsor_a) }
  let(:speaker_attrs) { { conference:, name: 'n', profile: 'p', company: 'c', job_title: 'j' } }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: sponsor_a_contact.email, name: sponsor_a_contact.name },
                                                                   extra: { raw_info: { sub: sponsor_a_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe '別スポンサー所属の Speaker への操作' do
    let!(:sponsor_b_speaker) { create(:speaker, **speaker_attrs, sponsor: sponsor_b) }

    it 'GET #edit は 404 を返す' do
      get edit_sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_b_speaker.id)
      expect(response).to(have_http_status(:not_found))
    end

    it 'PATCH #update は 404 を返し Speaker は変更されない' do
      original_name = sponsor_b_speaker.name
      patch sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_b_speaker.id),
            params: { speaker: { name: 'hacked' } }
      expect(response).to(have_http_status(:not_found))
      expect(sponsor_b_speaker.reload.name).to(eq(original_name))
    end

    it 'DELETE #destroy は 404 を返し Speaker は削除されない' do
      delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_b_speaker.id),
             headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to(have_http_status(:not_found))
      expect(Speaker.exists?(sponsor_b_speaker.id)).to(be(true))
    end
  end

  describe '自スポンサー所属の Speaker への操作' do
    let!(:sponsor_a_speaker) { create(:speaker, **speaker_attrs, sponsor: sponsor_a) }

    it 'GET #edit は 200 を返す' do
      get edit_sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_a_speaker.id)
      expect(response).to(have_http_status(:ok))
    end
  end

  describe 'DELETE #destroy のセマンティクス' do
    context 'sponsor_id のみで紐付く Speaker の場合（legacy）' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor: sponsor_a) }

      it 'Speaker 本体は削除されず、sponsor_id が nil にクリアされる' do
        delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: speaker.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(Speaker.exists?(speaker.id)).to(be(true))
        expect(speaker.reload.sponsor_id).to(be_nil)
        expect(sponsor_a.speakers).not_to(include(speaker))
      end
    end

    context 'SponsorSpeakerInviteAccept 経由で紐付く Speaker の場合（既存プロポーザル由来）' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor: nil) }
      let!(:invite) { create(:sponsor_speaker_invite, conference:, sponsor: sponsor_a) }
      let!(:invite_accept) do
        create(:sponsor_speaker_invite_accept,
               conference:, sponsor: sponsor_a, sponsor_contact: sponsor_a_contact, speaker:, sponsor_speaker_invite: invite)
      end

      it 'Speaker 本体は削除されず、invite_accept のみ削除される' do
        delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: speaker.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(Speaker.exists?(speaker.id)).to(be(true))
        expect(SponsorSpeakerInviteAccept.exists?(invite_accept.id)).to(be(false))
        expect(sponsor_a.speakers).not_to(include(speaker))
      end
    end

    context '通常プロポーザルの Talk を持つ Speaker の場合' do
      let!(:speaker) { create(:speaker, **speaker_attrs, sponsor: sponsor_a) }
      let!(:talk) { create(:talk1) }

      before { speaker.talks << talk }

      it 'Speaker 本体も Talk も削除されず、sponsor_id が nil にクリアされる' do
        delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: speaker.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(Speaker.exists?(speaker.id)).to(be(true))
        expect(Talk.exists?(talk.id)).to(be(true))
        expect(speaker.reload.sponsor_id).to(be_nil)
      end
    end
  end
end
