require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorSpeakerInvitesController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact) { create(:sponsor_alice, conference:, sponsor:) }
  let!(:sponsor_talk) { create(:talk1, conference:, sponsor:) }
  let!(:sponsor_speaker_invite) { create(:sponsor_speaker_invite, conference:, sponsor:) }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: sponsor_contact.email, name: sponsor_contact.name },
                                                                   extra: { raw_info: { sub: sponsor_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
    allow(SponsorSpeakerInviteMailer).to(receive(:invite).and_return(double(deliver_now: true)))
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_speaker_invites/new' do
    it 'returns a successful response' do
      get new_sponsor_dashboards_sponsor_speaker_invite_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'POST /sponsor_dashboards/:sponsor_id/sponsor_speaker_invites' do
    let(:valid_attributes) do
      {
        sponsor_speaker_invite: {
          email: 'new_speaker@example.com',
          sponsor_id: sponsor.id
        }
      }
    end

    context 'when the invite is created successfully' do
      # Mock the controller to render a specific template after successful save
      before do
        allow_any_instance_of(SponsorDashboards::SponsorSpeakerInvitesController).to(
          receive(:render).and_return(nil)
        )
      end

      it 'creates a new sponsor speaker invite and sends an email' do
        expect {
          post(sponsor_dashboards_sponsor_speaker_invites_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)
        }.to(change(SponsorSpeakerInvite, :count).by(1))

        # Verify the invite was created with the correct attributes
        new_invite = SponsorSpeakerInvite.last
        expect(new_invite.email).to(eq('new_speaker@example.com'))
        expect(new_invite.sponsor_id).to(eq(sponsor.id))
        expect(new_invite.conference_id).to(eq(conference.id))

        # Verify the email was sent
        expect(SponsorSpeakerInviteMailer).to(have_received(:invite))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          sponsor_speaker_invite: {
            email: '',
            sponsor_id: sponsor.id
          }
        }
      end

      it 'does not create a new sponsor speaker invite' do
        expect {
          post(sponsor_dashboards_sponsor_speaker_invites_path(event: conference.abbr, sponsor_id: sponsor.id), params: invalid_attributes)
        }.not_to(change(SponsorSpeakerInvite, :count))

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(flash.now[:alert]).to(include('への招待メール送信に失敗しました'))
      end
    end
  end

  describe 'DELETE /sponsor_dashboards/:sponsor_id/sponsor_speaker_invites/:id' do
    it 'destroys the sponsor speaker invite' do
      expect {
        delete(sponsor_dashboards_sponsor_speaker_invite_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_speaker_invite.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })
      }.to(change(SponsorSpeakerInvite, :count).by(-1))

      expect(response).to(be_successful)
      expect(flash.now[:notice]).to(eq('招待を削除しました'))
    end

    context 'when deletion fails' do
      before do
        allow_any_instance_of(SponsorSpeakerInvite).to(receive(:destroy).and_return(false))
      end

      it 'returns an error message' do
        delete(sponsor_dashboards_sponsor_speaker_invite_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_speaker_invite.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })
        expect(response).to(have_http_status(:unprocessable_entity))
        expect(flash.now[:alert]).to(eq('招待の削除に失敗しました'))
      end
    end
  end
end
