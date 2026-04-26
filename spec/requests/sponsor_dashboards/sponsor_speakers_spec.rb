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

  describe '別スポンサー所属の Speaker への操作は拒否される' do
    let!(:sponsor_b_speaker) { create(:speaker, **speaker_attrs, sponsor: sponsor_b) }

    it 'GET #edit は 403 を返す' do
      get edit_sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_b_speaker.id)
      expect(response).to(have_http_status(:forbidden))
    end

    it 'PATCH #update は 403 を返し Speaker は変更されない' do
      original_name = sponsor_b_speaker.name
      patch sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_b_speaker.id),
            params: { speaker: { name: 'hacked' } }
      expect(response).to(have_http_status(:forbidden))
      expect(sponsor_b_speaker.reload.name).to(eq(original_name))
    end

    it 'DELETE #destroy は 403 を返し Speaker は削除されない' do
      delete sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_b_speaker.id),
             headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to(have_http_status(:forbidden))
      expect(Speaker.exists?(sponsor_b_speaker.id)).to(be(true))
    end
  end

  describe '自スポンサー所属の Speaker への操作は許可される' do
    let!(:sponsor_a_speaker) { create(:speaker, **speaker_attrs, sponsor: sponsor_a) }

    it 'GET #edit は 200 を返す' do
      get edit_sponsor_dashboards_sponsor_speaker_path(event: conference.abbr, sponsor_id: sponsor_a.id, id: sponsor_a_speaker.id)
      expect(response).to(have_http_status(:ok))
    end
  end
end
