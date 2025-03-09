require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorContactInvitesController, type: :request) do
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
    allow(SponsorContactInviteMailer).to(receive(:invite).and_return(double(deliver_now: true)))
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_contact_invites/new' do
    it 'returns a successful response' do
      get new_sponsor_dashboards_sponsor_contact_invite_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    context 'when not logged in' do
      before do
        allow_any_instance_of(SponsorDashboards::SponsorContactInvitesController).to(receive(:logged_in?).and_return(false))
      end

      it 'redirects to login path' do
        get new_sponsor_dashboards_sponsor_contact_invite_path(event: conference.abbr, sponsor_id: sponsor.id)
        expect(response).to(redirect_to("/#{conference.abbr}/sponsor_dashboards/login"))
      end
    end
  end

  describe 'POST /sponsor_dashboards/:sponsor_id/sponsor_contact_invites' do
    let(:valid_attributes) do
      {
        sponsor_contact_invite: {
          email: 'new_contact@example.com',
          sponsor_id: sponsor.id
        }
      }
    end

    context 'with valid parameters' do
      before do
        allow(SponsorContactInviteMailer).to(receive_message_chain(:invite, :deliver_now))
      end

      it 'creates a new sponsor contact invite' do
        expect {
          post(sponsor_dashboards_sponsor_contact_invites_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)
        }.to(change(SponsorContactInvite, :count).by(1))

        expect(flash.now[:notice]).to(eq('招待メールを送信しました'))
      end

      it 'sets the correct attributes on the invite' do
        post(sponsor_dashboards_sponsor_contact_invites_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)

        invite = SponsorContactInvite.last
        expect(invite.email).to(eq('new_contact@example.com'))
        expect(invite.sponsor_id).to(eq(sponsor.id))
        expect(invite.conference_id).to(eq(conference.id))
        expect(invite.token).not_to(be_nil)
        expect(invite.expires_at).to(be_within(1.minute).of(1.days.from_now))
      end

      it 'sends an invitation email' do
        expect(SponsorContactInviteMailer).to(receive_message_chain(:invite, :deliver_now))

        post(sponsor_dashboards_sponsor_contact_invites_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          sponsor_contact_invite: {
            email: '', # Invalid: email is required
            sponsor_id: sponsor.id
          }
        }
      end

      it 'does not create a new sponsor contact invite' do
        expect {
          post(sponsor_dashboards_sponsor_contact_invites_path(event: conference.abbr, sponsor_id: sponsor.id),
               params: invalid_attributes, xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })
        }.not_to(change(SponsorContactInvite, :count))

        expect(response).to(have_http_status(:unprocessable_entity))
      end
    end
  end

  describe 'DELETE /sponsor_dashboards/:sponsor_id/sponsor_contact_invites/:id' do
    it 'destroys the sponsor contact invite' do
      expect {
        delete(sponsor_dashboards_sponsor_contact_invite_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact_invite.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })
      }.to(change(SponsorContactInvite, :count).by(-1))

      expect(flash.now[:notice]).to(eq('招待を削除しました'))
    end

    it 'destroys all previous invites with the same email' do
      # Create additional invites with the same email
      create(:sponsor_contact_invite, conference:, sponsor:, email: sponsor_contact_invite.email)
      create(:sponsor_contact_invite, conference:, sponsor:, email: sponsor_contact_invite.email)

      expect {
        delete(sponsor_dashboards_sponsor_contact_invite_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact_invite.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })
      }.to(change(SponsorContactInvite, :count).by(-3)) # Deletes all 3 invites

      expect(flash.now[:notice]).to(eq('招待を削除しました'))
    end

    context 'when deletion fails' do
      before do
        allow_any_instance_of(SponsorContactInvite).to(receive(:destroy).and_return(false))
      end

      it 'returns an error message' do
        delete(sponsor_dashboards_sponsor_contact_invite_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_contact_invite.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(flash.now[:alert]).to(eq('招待の削除に失敗しました'))
      end
    end
  end
end
