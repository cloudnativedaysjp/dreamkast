require 'rails_helper'

describe SpeakerInvitationAcceptsController, type: :request do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:speaker) { create(:speaker_alice, :with_talk1_registered, conference:) }
  let!(:talk) { speaker.talks.first }
  let!(:speaker_invitation) { create(:speaker_invitation, conference:, talk:, email: 'invited@example.com', expires_at: 1.day.from_now) }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: 'invited@example.com', name: 'Invited Speaker' },
                                                                   extra: { raw_info: { email_verified: true, sub: 'auth0|123', 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /invite' do
    it 'returns a successful response' do
      get speaker_invitation_accepts_invite_path(event: conference.abbr, token: speaker_invitation.token)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
      expect(response.body).to(include('共同スピーカーとして招待された方へ'))
    end

    it 'redirects if coming from Auth0' do
      get speaker_invitation_accepts_invite_path(event: conference.abbr, token: speaker_invitation.token, state: 'some_state')
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to(new_speaker_invitation_accept_path(token: speaker_invitation.token)))
    end
  end

  describe 'GET /new' do
    it 'returns a successful response' do
      get new_speaker_invitation_accept_path(event: conference.abbr, token: speaker_invitation.token)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'sets a flash alert if invitation is expired' do
      speaker_invitation.update_column(:expires_at, 1.day.ago)
      get new_speaker_invitation_accept_path(event: conference.abbr, token: speaker_invitation.token)
      expect(flash.now[:alert]).to(eq('招待の有効期限が切れています。再招待を依頼してください。'))
    end

    it '招待先と異なるアカウントでログインしている場合はメッセージを表示する' do
      speaker_invitation.update_column(:email, 'other@example.com')
      get new_speaker_invitation_accept_path(event: conference.abbr, token: speaker_invitation.token)
      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include('招待先と異なるアカウントでログインしています'))
      expect(response.body).not_to(include('登録する」ボタンをクリックしてください'))
    end

    it 'returns a 404 response' do
      get new_speaker_invitation_accept_path(event: conference.abbr, token: 'invalid_token')
      expect(response).to(have_http_status('404'))
    end
  end

  describe 'POST /create' do
    let(:valid_attributes) do
      {
        token: speaker_invitation.token,
        speaker: {
          speaker_invitation_id: speaker_invitation.id,
          name: 'Invited Speaker',
          profile: 'Test profile',
          company: 'Test Company',
          job_title: 'Developer',
          twitter_id: 'twitter_handle',
          github_id: 'github_handle'
        }
      }
    end

    it 'creates a new speaker and associates with the talk' do
      expect {
        post(speaker_invitation_accepts_path(event: conference.abbr), params: valid_attributes)
      }.to(change(Speaker, :count).by(1)
      .and(change(SpeakerInvitationAccept, :count).by(1)))

      expect(response).to(redirect_to(speaker_dashboard_path(event: conference.abbr)))
      expect(flash[:notice]).to(eq('Speaker was successfully added.'))

      new_speaker = Speaker.last
      expect(new_speaker.talks).to(include(talk))
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          token: speaker_invitation.token,
          speaker: {
            speaker_invitation_id: speaker_invitation.id,
            name: '' # Invalid: name is required
          }
        }
      end

      it 'does not create a new speaker' do
        expect {
          post(speaker_invitation_accepts_path(event: conference.abbr), params: invalid_attributes)
        }.to_not(change(Speaker, :count))
      end
    end
  end
end
