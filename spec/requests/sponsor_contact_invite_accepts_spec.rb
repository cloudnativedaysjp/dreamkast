require 'rails_helper'

RSpec.describe(SponsorContactInviteAcceptsController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact_invite) { create(:sponsor_contact_invite, conference:, sponsor:, email: 'invited@example.com') }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: 'invited@example.com', name: 'Invited Contact' },
                                                                   extra: { raw_info: { sub: 'auth0|123', 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /sponsor_contact_invite_accepts/invite' do
    it 'returns a successful response' do
      get sponsor_contact_invite_accepts_invite_path(event: conference.abbr, token: sponsor_contact_invite.token)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'redirects if coming from Auth0' do
      get sponsor_contact_invite_accepts_invite_path(event: conference.abbr, token: sponsor_contact_invite.token, state: 'some_state')
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to(new_sponsor_contact_invite_accept_path(token: sponsor_contact_invite.token)))
    end
  end

  describe 'GET /sponsor_contact_invite_accepts/new' do
    it 'returns a successful response' do
      get new_sponsor_contact_invite_accept_path(event: conference.abbr, token: sponsor_contact_invite.token)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'sets a flash alert if invitation is expired' do
      # sponsor_contact_invite.update!(expires_at: 1.day.ago)
      allow_any_instance_of(SponsorContactInvite).to(receive(:expires_at).and_return(1.day.ago))


      get new_sponsor_contact_invite_accept_path(event: conference.abbr, token: sponsor_contact_invite.token)
      expect(flash.now[:alert]).to(eq('招待メールが期限切れです。再度招待メールを送ってもらってください。'))
    end

    it 'returns a 404 response for invalid token' do
      get(new_sponsor_contact_invite_accept_path(event: conference.abbr, token: 'invalid_token'))
      expect(response).to(have_http_status('404'))
    end
  end

  describe 'POST /sponsor_contact_invite_accepts' do
    let(:valid_attributes) do
      {
        sponsor_contact: {
          sponsor_contact_invite_id: sponsor_contact_invite.id,
          sponsor_id: sponsor.id,
          name: 'Invited Contact'
        }
      }
    end

    it 'creates a new sponsor contact and accept record' do
      expect {
        post(sponsor_contact_invite_accepts_path(event: conference.abbr), params: valid_attributes)
      }.to(change(SponsorContact, :count).by(1)
                                         .and(change(SponsorContactInviteAccept, :count).by(1)))

      expect(response).to(redirect_to(sponsor_dashboards_path(event: conference.abbr, sponsor_id: sponsor.id)))
      expect(flash[:notice]).to(eq('Speaker was successfully added.'))
    end

    context 'when sponsor contact already exists' do
      let!(:existing_contact) { create(:sponsor_contact, conference:, sponsor:, email: 'invited@example.com') }

      it 'updates the existing contact and creates an accept record' do
        expect {
          post(sponsor_contact_invite_accepts_path(event: conference.abbr), params: valid_attributes)
        }.not_to(change(SponsorContact, :count))

        expect {
          post(sponsor_contact_invite_accepts_path(event: conference.abbr), params: valid_attributes)
        }.to(change(SponsorContactInviteAccept, :count).by(1))

        expect(response).to(redirect_to(sponsor_dashboards_path(event: conference.abbr, sponsor_id: sponsor.id)))
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(SponsorContact).to(receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(SponsorContact.new)))
      end

      it 'does not create a new sponsor contact' do
        expect {
          post(sponsor_contact_invite_accepts_path(event: conference.abbr), params: valid_attributes)
        }.not_to(change(SponsorContact, :count))

        expect(response).to(have_http_status('200'))
      end
    end
  end
end
