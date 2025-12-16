require 'rails_helper'

describe(SpeakerInvitationsController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:speaker) { create(:speaker_alice, :with_talk1_registered, conference:) }
  let!(:talk) { speaker.talks.first }

  before do
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
      if arg[1] == :userinfo
        session[:userinfo]
      else
        arg[0].send(:original, arg[1])
      end
    end)
  end

  describe 'GET /new' do
    subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
    let(:roles) { [] }

    it 'returns a successful response' do
      get new_speaker_invitation_path(talk_id: talk.id, event: conference.abbr)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it "returns 404 if talk doesn't belong to speaker" do
      other_talk = create(:talk2, conference:)
      get new_speaker_invitation_path(talk_id: other_talk.id, event: conference.abbr)
      expect(response).to(have_http_status('404'))
    end
  end

  describe 'POST /create' do
    subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
    let(:roles) { [] }
    let(:valid_attributes) { { email: 'co-speaker@example.com', talk_id: talk.id } }

    it 'returns a redirect response for authenticated user' do
      post(speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: valid_attributes })
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to('/cndt2020/speaker_dashboard'))
      expect(flash.now[:notice]).to(eq('Invitation sent!'))
    end

    it 'creates a new speaker invitation' do
      expect {
        post(speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: valid_attributes })
      }.to(change(SpeakerInvitation, :count).by(1))
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { email: '', talk_id: talk.id } }

      it 'does not create a new speaker invitation' do
        expect {
          post(speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: invalid_attributes })
        }.not_to(change(SpeakerInvitation, :count))
      end

      it 'sets an error flash message' do
        post speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: invalid_attributes }
        expect(flash[:alert]).to(eq(' への招待メール送信に失敗しました: Emailを入力してください'))
      end

      it 'redirects to the speaker dashboard' do
        post speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: invalid_attributes }
        expect(response).to(redirect_to(new_speaker_invitation_path(event: conference.abbr, talk_id: talk.id)))
      end
    end
  end
end
