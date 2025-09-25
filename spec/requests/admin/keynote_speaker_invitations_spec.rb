require 'rails_helper'

RSpec.describe('Admin::KeynoteSpeakerInvitations', type: :request) do
  let(:conference) { create(:cndt2020, :registered) }
  let(:valid_attributes) do
    {
      email: 'keynote@example.com',
      name: 'キーノートスピーカー'
    }
  end
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'aaa' } }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }

  before do
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
      if arg[1] == :userinfo
        session[:userinfo]
      else
        arg[0].send(:original, arg[1])
      end
    end)
    allow_any_instance_of(Admin::KeynoteSpeakerInvitationsController).to(receive(:admin?).and_return(true))
    allow(KeynoteSpeakerInvitationMailer).to(receive(:invite).and_return(double(deliver_now: true)))
    allow(KeynoteSpeakerInvitationMailer).to(receive(:accepted).and_return(double(deliver_now: true)))
    create(:talk_type, :keynote)
    create(:proposal_item_configs_session_time_40_min, conference:)
    create(:proposal_item_configs_session_time_20_min, conference:)
  end

  describe 'GET /admin/keynote_speaker_invitations' do
    it '招待一覧が表示される' do
      create(:keynote_speaker_invitation, conference:)
      get admin_keynote_speaker_invitations_path(event: conference.abbr)
      expect(response).to(have_http_status(:success))
    end
  end

  describe 'GET /admin/keynote_speaker_invitations/new' do
    it '新規招待フォームが表示される' do
      get new_admin_keynote_speaker_invitation_path(event: conference.abbr)
      expect(response).to(have_http_status(:success))
    end
  end

  describe 'POST /admin/keynote_speaker_invitations' do
    context '有効なパラメータの場合' do
      it '招待が作成される' do
        expect do
          post(admin_keynote_speaker_invitations_path(event: conference.abbr),
               params: { keynote_speaker_invitation: valid_attributes },
               headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' })
        end.to(change(KeynoteSpeakerInvitation, :count).by(1))
      end

      it '関連するSpeaker、Talk、Proposalが作成される' do
        expect do
          post(admin_keynote_speaker_invitations_path(event: conference.abbr),
               params: { keynote_speaker_invitation: valid_attributes },
               headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' })
        end.to(change(Speaker, :count).by(1)
                                      .and(change(Talk, :count).by(1)
          .and(change(Proposal, :count).by(1))))
      end

      it '招待メールが送信される' do
        expect(KeynoteSpeakerInvitationMailer).to(receive(:invite).with(kind_of(KeynoteSpeakerInvitation)).and_return(double(deliver_now: true)))
        post admin_keynote_speaker_invitations_path(event: conference.abbr),
             params: { keynote_speaker_invitation: valid_attributes },
             headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
      end

      it '成功で200が返る(redirectではない)' do
        post admin_keynote_speaker_invitations_path(event: conference.abbr),
             params: { keynote_speaker_invitation: valid_attributes },
             headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response).to(have_http_status(:ok))
        expect(flash.now[:notice]).to(eq('招待メールを送信しました。'))
      end
    end

    context '無効なパラメータの場合' do
      it '招待が作成されない' do
        expect do
          post(admin_keynote_speaker_invitations_path(event: conference.abbr),
               params: { keynote_speaker_invitation: { email: '' } })
        end.not_to(change(KeynoteSpeakerInvitation, :count))
      end

      it 'エラーメッセージが表示される' do
        post admin_keynote_speaker_invitations_path(event: conference.abbr),
             params: { keynote_speaker_invitation: { email: '' } }
        expect(response).to(have_http_status(:unprocessable_entity))
      end
    end
  end

  describe 'POST /admin/keynote_speaker_invitations/:id/resend' do
    let(:invitation) { create(:keynote_speaker_invitation, conference:) }

    context 'まだ承諾されていない招待の場合' do
      it '招待メールが再送信される' do
        expect(KeynoteSpeakerInvitationMailer).to(receive(:invite).with(kind_of(KeynoteSpeakerInvitation)).and_return(double(deliver_now: true)))
        post resend_admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id),
             headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
      end

      it '有効期限が更新される' do
        old_expires_at = invitation.expires_at
        post resend_admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id),
             headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(invitation.reload.expires_at).to(be > old_expires_at)
      end

      it '成功で200が返る(redirectではない)' do
        post resend_admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id),
             headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response).to(have_http_status(:ok))
      end
    end

    context '既に承諾済みの招待の場合' do
      let(:invitation) { create(:keynote_speaker_invitation, :accepted, conference:) }

      it 'エラーメッセージが表示される' do
        post resend_admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id)
        expect(flash[:alert]).to(include('承諾済みの招待は再送信できません'))
      end
    end
  end

  describe 'DELETE /admin/keynote_speaker_invitations/:id' do
    let(:invitation) { create(:keynote_speaker_invitation, conference:) }

    context 'まだ承諾されていない招待の場合' do
      it '招待と関連データが削除される' do
        invitation_id = invitation.id
        speaker = invitation.speaker
        talk = invitation.talk

        delete admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation_id),
               headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

        expect(KeynoteSpeakerInvitation.find_by(id: invitation_id)).to(be_nil)
        expect(Speaker.find_by(id: speaker.id)).to(be_nil)
        expect(Talk.find_by(id: talk.id)).to(be_nil)
      end

      it '成功で200が返る(redirectではない)' do
        delete admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id),
               headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response).to(have_http_status(:ok))
      end
    end

    context '既に承諾済みの招待の場合' do
      let(:invitation) { create(:keynote_speaker_invitation, :accepted, conference:) }

      it '削除されない' do
        delete admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id),
               headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(invitation.reload).to(be_present)
      end

      it 'エラーメッセージが表示される' do
        delete admin_keynote_speaker_invitation_path(event: conference.abbr, id: invitation.id),
               headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(flash[:alert]).to(include('承諾済みの招待は削除できません'))
      end
    end
  end
end
