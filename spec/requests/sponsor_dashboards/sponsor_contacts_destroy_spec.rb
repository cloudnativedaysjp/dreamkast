require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorContactsController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact) { create(:sponsor_alice, conference:, sponsor:) }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: sponsor_contact.email, name: sponsor_contact.name },
                                                                   extra: { raw_info: { sub: sponsor_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'DELETE /sponsor_dashboards/:sponsor_id/sponsor_contacts/:id' do
    it 'sets a flash notice and returns a successful turbo_stream response' do
      delete sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact.id),
             xhr: true, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to(be_successful)
      expect(response.content_type).to(include('text/vnd.turbo-stream.html'))
      expect(flash[:notice]).to(eq("スポンサー担当者 #{sponsor_contact.email} を削除しました"))
    end

    it 'removes the sponsor contact from the database' do
      expect {
        delete(sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact.id),
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' })
      }.to(change(SponsorContact, :count).by(-1))

      expect(SponsorContact.exists?(sponsor_contact.id)).to(be_falsey)
    end

    it 'includes the turbo_stream to remove the sponsor contact' do
      delete sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact.id),
             headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response.body).to(include('turbo-stream action="remove"'))
      expect(response.body).to(include("target=\"sponsor_contact_#{sponsor_contact.id}\""))
    end
  end

  it 'sets a flash alert and renders new template when destroy fails' do
    allow_any_instance_of(SponsorContact).to(receive(:destroy).and_return(false))

    delete sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact.id),
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

    expect(response).to(have_http_status(:unprocessable_entity))
    expect(flash[:alert]).to(eq("スポンサー担当者 #{sponsor_contact.email} の削除に失敗しました"))
  end

  it 'returns 404 when sponsor contact does not exist' do
    delete(sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: 999999),
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' })
    expect(response).to(have_http_status(:not_found))
  end
end
