require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorContactsController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact) { create(:sponsor_alice, conference:, sponsor:) }
  let!(:sponsor_contact_invite) { create(:sponsor_contact_invite, conference:, sponsor:) }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: sponsor_contact.email, name: sponsor_contact.name },
                                                                   extra: { raw_info: { sub: sponsor_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_contacts' do
    it 'returns a successful response' do
      get sponsor_dashboards_sponsor_contacts_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_contacts/new' do
    context 'when logged in' do
      # For this test, we need to use a different email than the one already associated with a sponsor contact
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                     {
                                                                       info: { email: 'new_user@example.com', name: 'New User' },
                                                                       extra: { raw_info: { sub: 'new_user_sub', 'https://cloudnativedays.jp/roles' => [] } }
                                                                     }
                                                                   ))
      end

      it 'returns a successful response' do
        get new_sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id)
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
      end

      it 'redirects to sponsor_dashboards_path if user is already a sponsor contact' do
        # Create a sponsor contact with the same email as the current user
        new_user = User.find_or_create_by!(sub: 'new_user_sub') { |u| u.email = 'new_user@example.com' }
        create(:sponsor_contact, conference:, sponsor: sponsor_contact.sponsor, user_id: new_user.id)

        get new_sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id)
        expect(response).to(redirect_to(sponsor_dashboards_path))
      end
    end

    context 'when not logged in' do
      before do
        allow_any_instance_of(SponsorDashboards::SponsorContactsController).to(receive(:logged_in?).and_return(false))
      end

      it 'redirects to login path' do
        get new_sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id)
        expect(response).to(redirect_to(auth_login_path(origin: request.fullpath)))
      end
    end
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_contacts/:id/edit' do
    it 'returns a successful response' do
      get edit_sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'POST /sponsor_dashboards/:sponsor_id/sponsor_contacts' do
    context 'when sponsor contact does not exist for the current user' do
      let(:new_user_email) { 'new_user@example.com' }
      let(:new_user_sub) { 'new_user_sub' }
      let(:valid_attributes) do
        {
          sponsor_contact: {
            name: 'New Contact',
            email: new_user_email
          }
        }
      end

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                     {
                                                                       info: { email: new_user_email, name: 'New User' },
                                                                       extra: { raw_info: { sub: new_user_sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                     }
                                                                   ))
      end

      it 'creates a new sponsor contact' do
        expect {
          post(sponsor_dashboards_sponsor_contacts_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)
        }.to(change(SponsorContact, :count).by(1))

        expect(response).to(redirect_to("/#{conference.abbr}/sponsor_dashboards/#{sponsor.id}"))
        expect(flash[:notice]).to(eq('Speaker was successfully created.'))
      end
    end

    context 'when sponsor contact already exists for the current user' do
      let(:valid_attributes) do
        {
          sponsor_contact: {
            name: 'New Contact',
            email: sponsor_contact.email
          }
        }
      end

      it 'redirects with an error message' do
        expect {
          post(sponsor_dashboards_sponsor_contacts_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)
        }.not_to(change(SponsorContact, :count))

        expect(response).to(redirect_to("/#{conference.abbr}/sponsor_dashboards"))
        expect(flash[:notice]).to(eq('ログインが許可されていません'))
      end
    end
  end

  describe 'PUT /sponsor_dashboards/:sponsor_id/sponsor_contacts/:id' do
    let(:valid_attributes) do
      {
        sponsor_contact: {
          name: 'Updated Contact Name'
        }
      }
    end

    it 'updates the sponsor contact' do
      put sponsor_dashboards_sponsor_contact_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact.id), params: valid_attributes
      expect(response).to(redirect_to(sponsor_dashboards_path))
      expect(flash[:notice]).to(eq('Speaker was successfully updated.'))
      expect(sponsor_contact.reload.name).to(eq('Updated Contact Name'))
    end
  end
end
