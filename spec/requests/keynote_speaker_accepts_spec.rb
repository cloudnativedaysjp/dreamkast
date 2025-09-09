require 'rails_helper'

RSpec.describe('KeynoteSpeakerAccepts', type: :request) do
  let(:conference) { create(:cndt2020, :registered) }

  before do
    create(:talk_type, :keynote)
    create(:proposal_item_configs_session_time_40_min, conference:)
    create(:proposal_item_configs_session_time_20_min, conference:)
    allow(KeynoteSpeakerInvitationMailer).to(receive_message_chain(:accepted, :deliver_later))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: 'invited@example.com', name: 'Invited Speaker' },
                                                                   extra: { raw_info: { sub: 'auth0|123', 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /keynote_speaker_accepts/:token' do
    context '有効なトークンの場合' do
      let(:invitation) { create(:keynote_speaker_invitation, conference:) }
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it '承諾画面が表示される' do
        get keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(have_http_status(:success))
      end
    end

    context '無効なトークンの場合' do
      let(:invitation) { create(:keynote_speaker_invitation, conference:) }
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it '404エラーが返される' do
        get keynote_speaker_accept_path(event: conference.abbr, token: 'invalid_token')
        expect(response).to(have_http_status(:not_found))
      end
    end

    context '期限切れの招待の場合' do
      let!(:invitation) do
        create(:keynote_speaker_invitation, conference:).tap do |inv|
          inv.update!(expires_at: 1.day.ago, invited_at: 8.days.ago)
        end
      end
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it '期限切れ画面が表示される' do
        get keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(have_http_status(:ok))
      end
    end

    context '既に承諾済みの招待の場合' do
      let(:invitation) { create(:keynote_speaker_invitation, :accepted, conference:) }
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it 'speaker_dashboardにリダイレクトされる' do
        get keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(redirect_to(speaker_dashboard_path(event: conference.abbr)))
      end
    end

    context 'ログインしていない場合' do
      let(:invitation) { create(:keynote_speaker_invitation, conference:) }

      before do
        allow_any_instance_of(KeynoteSpeakerAcceptsController).to(receive(:logged_in?).and_return(false))
      end

      it 'Auth0ログインにリダイレクトされる' do
        get keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(redirect_to("/#{conference.abbr}/auth/auth0"))
      end

      it 'return_toがセッションに保存される' do
        get keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(session[:return_to]).to(eq(request.url))
      end
    end
  end

  describe 'POST /keynote_speaker_accepts/:token' do
    context '有効な招待の場合' do
      let(:invitation) { create(:keynote_speaker_invitation, conference:) }
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it '招待が承諾される' do
        expect do
          post(keynote_speaker_accept_path(event: conference.abbr, token: invitation.token))
        end.to(change { invitation.reload.accepted_at }.from(nil))
      end

      it 'KeynoteSpeakerAcceptが作成される' do
        expect do
          post(keynote_speaker_accept_path(event: conference.abbr, token: invitation.token))
        end.to(change(KeynoteSpeakerAccept, :count).by(1))
      end

      it 'SpeakerにAuth0のsubが設定される' do
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(invitation.speaker.reload.sub).to(eq('auth0|123'))
      end

      it '承諾確認メールが送信される' do
        expect(KeynoteSpeakerInvitationMailer).to(receive(:accepted).and_call_original)
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
      end

      it 'speaker_dashboardにリダイレクトされる' do
        expect(KeynoteSpeakerInvitationMailer).to(receive(:accepted).and_call_original)
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(redirect_to(speaker_dashboard_path(event: conference.abbr)))
      end

      it '成功メッセージが表示される' do
        expect(KeynoteSpeakerInvitationMailer).to(receive(:accepted).and_call_original)
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(flash[:notice]).to(include('キーノートスピーカーとしての招待を承諾しました'))
      end
    end

    context '無効なトークンの場合' do
      let(:invitation) { create(:keynote_speaker_invitation, conference:) }
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it '404エラーが返される' do
        post keynote_speaker_accept_path(event: conference.abbr, token: 'invalid_token')
        expect(response).to(have_http_status(:not_found))
      end
    end

    context '期限切れの招待の場合' do
      let!(:invitation) do
        create(:keynote_speaker_invitation, conference:).tap do |inv|
          inv.update!(expires_at: 1.day.ago, invited_at: 8.days.ago)
        end
      end
      let(:current_user) do
        {
          info: { email: invitation.email, name: 'Test User' },
          extra: { raw_info: { sub: 'auth0|test123', 'https://cloudnativedays.jp/roles' => [] } }
        }
      end

      before do
        allow_any_instance_of(KeynoteSpeakerAcceptsController).to(receive(:logged_in?).and_return(true))
        allow_any_instance_of(KeynoteSpeakerAcceptsController).to(receive(:current_user).and_return(current_user))
      end

      it '期限切れ画面が表示される' do
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include('招待の有効期限'))
      end
    end

    context '既に承諾済みの招待の場合' do
      let(:invitation) { create(:keynote_speaker_invitation, :accepted, conference:) }
      let(:current_user) { { sub: 'auth0|test123', info: { email: invitation.email } } }

      it 'speaker_dashboardにリダイレクトされる' do
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(response).to(redirect_to(speaker_dashboard_path(event: conference.abbr)))
      end

      it 'エラーメッセージが表示される' do
        post keynote_speaker_accept_path(event: conference.abbr, token: invitation.token)
        expect(flash[:alert]).to(include('この招待は既に承諾済みです'))
      end
    end
  end
end
