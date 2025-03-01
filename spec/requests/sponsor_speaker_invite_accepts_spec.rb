require 'rails_helper'

RSpec.describe(SponsorSpeakerInviteAcceptsController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_speaker_invite) { create(:sponsor_speaker_invite, conference:, sponsor:, email: 'invited@example.com') }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: 'invited@example.com', name: 'Invited Speaker' },
                                                                   extra: { raw_info: { sub: 'auth0|123', 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /sponsor_speaker_invite_accepts/invite' do
    it 'returns a successful response' do
      get sponsor_speaker_invite_accepts_invite_path(event: conference.abbr, token: sponsor_speaker_invite.token)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'redirects if coming from Auth0' do
      get sponsor_speaker_invite_accepts_invite_path(event: conference.abbr, token: sponsor_speaker_invite.token, state: 'some_state')
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to(new_sponsor_speaker_invite_accept_path(token: sponsor_speaker_invite.token)))
    end
  end

  describe 'GET /sponsor_speaker_invite_accepts/new' do
    it 'returns a successful response' do
      get new_sponsor_speaker_invite_accept_path(event: conference.abbr, token: sponsor_speaker_invite.token)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'sets a flash alert if invitation is expired' do
      sponsor_speaker_invite.update(expires_at: 1.day.ago)
      get new_sponsor_speaker_invite_accept_path(event: conference.abbr, token: sponsor_speaker_invite.token)
      expect(flash.now[:alert]).to(eq('招待メールが期限切れです。再度招待メールを送ってもらってください。'))
    end

    it 'returns a 404 response for invalid token' do
      get(new_sponsor_speaker_invite_accept_path(event: conference.abbr, token: 'invalid_token'))
      expect(response).to(have_http_status('404'))
    end
  end

  describe 'POST /sponsor_speaker_invite_accepts' do
    let(:valid_attributes) do
      {
        speaker: {
          sponsor_speaker_invite_id: sponsor_speaker_invite.id,
          sponsor_id: sponsor.id,
          name: 'Invited Speaker',
          profile: 'Test profile',
          company: 'Test Company',
          job_title: 'Developer'
        }
      }
    end

    it 'creates a new sponsor contact, speaker, and accept record' do
      expect {
        post(sponsor_speaker_invite_accepts_path(event: conference.abbr), params: valid_attributes)
      }.to(change(SponsorContact, :count).by(1)
                                         .and(change(Speaker, :count).by(1)
        .and(change(SponsorSpeakerInviteAccept, :count).by(1))))

      expect(response).to(redirect_to(sponsor_dashboards_path(event: conference.abbr, sponsor_id: sponsor.id)))
      expect(flash[:notice]).to(eq('Speaker was successfully added.'))
    end

    context 'when sponsor contact already exists' do
      let!(:existing_contact) { create(:sponsor_contact, conference:, sponsor:, email: 'invited@example.com') }

      it 'uses the existing contact and creates speaker and accept records' do
        expect {
          post(sponsor_speaker_invite_accepts_path(event: conference.abbr), params: valid_attributes)
        }.to(change(Speaker, :count).by(1)
                                    .and(change(SponsorSpeakerInviteAccept, :count).by(1)))

        # Check that SponsorContact count doesn't change
        expect(SponsorContact.count).to(eq(1))

        expect(response).to(redirect_to(sponsor_dashboards_path(event: conference.abbr, sponsor_id: sponsor.id)))
      end
    end

    context 'when speaker already exists' do
      let!(:existing_contact) { create(:sponsor_contact, conference:, sponsor:, email: 'invited@example.com') }
      let!(:existing_speaker) {
        create(:speaker,
               conference:,
                     sponsor:,
                     email: 'invited@example.com',
                     name: 'Existing Speaker',
                     profile: 'Existing profile',
                     company: 'Existing Company',
                     job_title: 'Existing Job')
      }

      it 'updates the existing speaker and creates an accept record' do
        # Check that SponsorSpeakerInviteAccept count increases but Speaker count doesn't
        speaker_count_before = Speaker.count

        expect {
          post(sponsor_speaker_invite_accepts_path(event: conference.abbr), params: valid_attributes)
        }.to(change(SponsorSpeakerInviteAccept, :count).by(1))

        # Verify Speaker count didn't change
        expect(Speaker.count).to(eq(speaker_count_before))

        expect(response).to(redirect_to(sponsor_dashboards_path(event: conference.abbr, sponsor_id: sponsor.id)))
        expect(existing_speaker.reload.name).to(eq('Invited Speaker'))
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(Speaker).to(receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Speaker.new)))
      end

      it 'does not create a new speaker' do
        expect {
          post(sponsor_speaker_invite_accepts_path(event: conference.abbr), params: valid_attributes)
        }.not_to(change(Speaker, :count))

        expect(response).to(have_http_status('200'))
      end
    end
  end
end
