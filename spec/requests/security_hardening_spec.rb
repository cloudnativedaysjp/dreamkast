require 'rails_helper'

RSpec.describe('セキュリティ境界', type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let(:user) { create(:user) }

  def login_as(user, verified: true, roles: [])
    auth = { info: { email: user.email }, extra: { raw_info: { sub: user.sub, email_verified: verified, 'https://cloudnativedays.jp/roles' => roles } } }
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(auth))
  end

  describe '公開セッション検索' do
    let!(:talk) { create(:talk1, :accepted) }

    ['1 OR 1=1', '1); SELECT 1; --', '', '1,,2', ['1'], '1,' * 101].each do |value|
      it "不正な日付ID #{value.inspect} を拒否する" do
        get '/api/v1/talks', params: { eventAbbr: conference.abbr, conferenceDayIds: value }
        expect(response).to(have_http_status(:bad_request))
      end
    end

    it '数値IDだけの検索を許可する' do
      get '/api/v1/talks', params: { eventAbbr: conference.abbr, conferenceDayIds: talk.conference_day_id.to_s }
      expect(response).to(have_http_status(:ok))
      expect(JSON.parse(response.body).pluck('id')).to(include(talk.id))
    end
  end

  describe 'スポンサー管理' do
    let!(:sponsor) { create(:sponsor, conference:) }
    let!(:talk) { create(:talk1, sponsor:) }

    before { login_as(user) }

    it '一般ユーザーに担当者一覧を開示しない' do
      get sponsor_dashboards_sponsor_contacts_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(have_http_status(:forbidden))
    end

    it '一般ユーザーの担当者自己登録を拒否する' do
      expect {
        post sponsor_dashboards_sponsor_contacts_path(event: conference.abbr, sponsor_id: sponsor.id), params: { sponsor_contact: { name: '不正登録' } }
      }.not_to(change(SponsorContact, :count))
      expect(response).to(have_http_status(:forbidden))
    end

    it '一般ユーザーのセッション削除を拒否する' do
      expect {
        delete sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id, id: talk.id)
      }.not_to(change(Talk, :count))
      expect(response).to(have_http_status(:forbidden))
    end

    it '自スポンサーのURLに別スポンサーのセッションIDを指定しても削除できない' do
      own_sponsor = create(:sponsor, conference:, id: 98)
      create(:sponsor_contact, conference:, sponsor: own_sponsor, user:)
      expect {
        delete sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: own_sponsor.id, id: talk.id)
      }.not_to(change(Talk, :count))
      expect(response).to(have_http_status(:not_found))
    end

    it '所属するスポンサーの一覧を表示できる' do
      create(:sponsor_contact, conference:, sponsor:, user:)
      get sponsor_dashboards_sponsor_contacts_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(have_http_status(:ok))
    end
  end

  describe '招待承認' do
    [
      [:sponsor_contact_invite, SponsorContactInviteAccept, :sponsor_contact, 'sponsor_contact_invite_accepts'],
      [:sponsor_speaker_invite, SponsorSpeakerInviteAccept, :speaker, 'sponsor_speaker_invite_accepts'],
      [:speaker_invitation, SpeakerInvitationAccept, :speaker, 'speaker_invitation_accepts']
    ].each do |factory, acceptance, form_key, route|
      context route do
        let!(:invitation) do
          attrs = { conference: conference, email: user.email, expires_at: 1.day.from_now, token: SecureRandom.hex(32) }
          if factory == :speaker_invitation
            attrs[:talk] = create(:talk1)
          else
            attrs[:sponsor] = create(:sponsor, conference:)
          end
          create(factory, **attrs)
        end
        let(:path) { "/#{conference.abbr}/#{route}" }
        let(:attributes) { { token: invitation.token, form_key => { name: '登壇者', profile: '紹介', company: '会社', job_title: '開発者' } } }

        before { login_as(user) }

        it 'トークンの代わりに数値IDだけを送っても承認しない' do
          attributes.delete(:token)
          attributes[form_key]["#{factory}_id"] = invitation.id
          expect { post path, params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:not_found))
        end

        it '期限切れのトークンを拒否する' do
          invitation.update_column(:expires_at, 1.minute.ago)
          expect { post path, params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:forbidden))
        end

        it '宛先以外の利用者を拒否する' do
          login_as(create(:user))
          expect { post path, params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:forbidden))
        end

        it 'メールアドレス未検証の利用者を拒否する' do
          login_as(user, verified: false)
          expect { post path, params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:forbidden))
        end

        it '別イベントに対して承認できない' do
          other = create(:cndo2021)
          expect { post "/#{other.abbr}/#{route}", params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:not_found))
        end

        it '正しい宛先による承認を一度だけ許可する' do
          expect { post path, params: attributes }.to(change(acceptance, :count).by(1))
          expect { post path, params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:forbidden))
        end

        it '承認レコードを削除しても使用済みトークンを再利用できない' do
          post path, params: attributes
          expect(invitation.reload.accepted_at).to(be_present)
          acceptance.where("#{factory}_id" => invitation.id).delete_all
          expect { post path, params: attributes }.not_to(change(acceptance, :count))
          expect(response).to(have_http_status(:forbidden))
        end
      end
    end
  end

  describe 'イベント管理の境界' do
    let!(:talk) { create(:talk1) }
    let!(:video) { create(:video, :off_air, talk:) }
    let!(:other_conference) { create(:cndo2021) }

    before { login_as(user, roles: ["#{other_conference.abbr.upcase}-Admin"]) }

    it '別イベントのセッションを編集画面で取得できない' do
      get edit_admin_talk_path(event: other_conference.abbr, id: talk.id)
      expect(response).to(have_http_status(:not_found))
    end

    it '一括更新でも別イベントの配信を変更できない' do
      expect {
        TalksHelper.update_talks(other_conference, { talk.id.to_s => { on_air: true } })
      }.to(raise_error(ActiveRecord::RecordNotFound))
      expect(video.reload.on_air).to(be(false))
    end

    it '自イベントのセッションを別イベントのトラックに付け替えられない' do
      login_as(user, roles: ["#{conference.abbr.upcase}-Admin"])
      original_track = talk.track_id
      patch admin_talk_path(event: conference.abbr, id: talk.id), params: { talk: { track_id: other_conference.tracks.first.id } }
      expect(response).to(have_http_status(:not_found))
      expect(talk.reload.track_id).to(eq(original_track))
    end

    it '別イベントのスポンサーに招待を作成できない' do
      sponsor = create(:sponsor, conference:)
      expect {
        post admin_sponsor_contact_invites_path(event: other_conference.abbr), params: { sponsor_contact_invite: { sponsor_id: sponsor.id, email: user.email } }
      }.not_to(change(SponsorContactInvite, :count))
      expect(response).to(have_http_status(:not_found))
    end

    it '登壇者のCSVに別イベントの情報を含めない' do
      foreign_speaker = create(:speaker_alice, conference:)
      get admin_export_speakers_path(event: other_conference.abbr)
      expect(response).to(have_http_status(:ok))
      expect(CSV.parse(response.body).drop(1).map(&:first)).not_to(include(foreign_speaker.id.to_s))
    end

    it '登壇者の編集時にイベントを維持する' do
      login_as(user, roles: ["#{conference.abbr.upcase}-Admin"])
      speaker = create(:speaker_alice, conference:)
      attributes = speaker.attributes.slice('name', 'profile', 'company', 'job_title').merge('name' => '更新した登壇者', 'conference_id' => other_conference.id)
      patch admin_speaker_path(event: conference.abbr, id: speaker.id), params: { speaker: attributes }
      expect(response).to(have_http_status(:redirect))
      expect(speaker.reload.name).to(eq('更新した登壇者'))
      expect(speaker.conference_id).to(eq(conference.id))
    end
  end

  describe '登壇者による編集の境界' do
    let!(:speaker) { create(:speaker_alice, :with_talk1_registered, conference:, user:) }
    let!(:talk) { speaker.talks.first }
    let!(:other_conference) { create(:cndo2021) }

    before { login_as(user) }

    def update_talk(talk_attributes, speaker_attributes = {})
      patch speaker_dashboard_speaker_path(event: conference.abbr, id: speaker.id),
            params: { speaker: speaker.attributes.slice('name', 'profile', 'company', 'job_title')
                                      .merge('talks_attributes' => { '0' => { id: talk.id, title: talk.title }.merge(talk_attributes) })
                                      .merge(speaker_attributes) }
    end

    it '自分のセッションを任意のスポンサーセッションにできない' do
      sponsor = create(:sponsor, conference:)
      update_talk({ sponsor_id: sponsor.id })
      expect(response).to(redirect_to(speaker_dashboard_path(event: conference.abbr)))
      expect(talk.reload.sponsor_id).to(be_nil)
    end

    it '登壇者情報を別イベントへ付け替えられない' do
      update_talk({}, { conference_id: other_conference.id })
      expect(response).to(redirect_to(speaker_dashboard_path(event: conference.abbr)))
      expect(speaker.reload.conference_id).to(eq(conference.id))
    end

    it '別イベントのカテゴリを指定できない' do
      category = create(:talk_category, id: 999, conference: other_conference, name: '別イベント')
      update_talk({ talk_category_id: category.id })
      expect(response).to(have_http_status(:not_found))
      expect(talk.reload.talk_category_id).not_to(eq(category.id))
    end

    it '自分が登壇しないセッションへ共同登壇者を招待できない' do
      other_talk = create(:talk2, conference:)
      expect {
        post speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: { email: 'alt@example.com', talk_id: other_talk.id } }
      }.not_to(change(SpeakerInvitation, :count))
      expect(response).to(have_http_status(:not_found))
    end

    it '自分のセッションへは共同登壇者を招待できる' do
      expect {
        post speaker_invitations_path(event: conference.abbr), params: { speaker_invitation: { email: 'co-speaker@example.com', talk_id: talk.id } }
      }.to(change(SpeakerInvitation, :count).by(1))
    end
  end

  describe '配信管理API' do
    let!(:talk) { create(:talk1) }
    let!(:video) { create(:video, :off_air, talk:) }
    let(:claims) { claim.first.merge('https://cloudnativedays.jp/roles' => []) }

    before { allow(JsonWebToken).to(receive(:verify).and_return([claims])) }

    it '一般APIトークンでは配信状態を変更できない' do
      put "/api/v1/talks/#{talk.id}", params: { on_air: true }, as: :json
      expect(response).to(have_http_status(:forbidden))
      expect(video.reload.on_air).to(be(false))
    end

    it '別イベントの管理者でも変更できない' do
      claims['https://cloudnativedays.jp/roles'] = ['OTHER-Admin']
      put "/api/v1/talks/#{talk.id}", params: { on_air: true }, as: :json
      expect(response).to(have_http_status(:forbidden))
    end

    it '一般APIトークンでは動画URLを変更できない' do
      expect {
        put "/api/v1/talks/#{talk.id}/video_registration", params: { url: 'https://example.com/movie' }, as: :json
      }.not_to(change(VideoRegistration, :count))
      expect(response).to(have_http_status(:forbidden))
    end

    it '用途を限定したM2Mトークンを許可する' do
      claims.merge!('gty' => 'client-credentials', 'scope' => 'update:streamings')
      put "/api/v1/talks/#{talk.id}", params: { on_air: true }, as: :json
      expect(response).to(have_http_status(:ok))
      expect(video.reload.on_air).to(be(true))
    end
  end

  describe 'アバターアップロード' do
    before { UploadsController::RATE_LIMIT_STORE.clear }

    it '未認証のアップロードを拒否する' do
      post '/upload/avatar'
      expect(response).to(have_http_status(:unauthorized))
    end

    it '認証済みでもCSRFトークンなしでは拒否する' do
      login_as(user)
      allow_any_instance_of(UploadsController).to(receive(:protect_against_forgery?).and_return(true))
      post '/upload/avatar'
      expect(response).to(have_http_status(:unprocessable_entity))
    end

    it '画像を装ったHTMLを拒否する' do
      login_as(user)
      Tempfile.create(['avatar', '.png']) do |file|
        file.write('<html><script>alert(1)</script></html>')
        file.flush
        post '/upload/avatar', params: { file: Rack::Test::UploadedFile.new(file.path, 'image/png') }
      end
      expect(response).to(have_http_status(:unsupported_media_type))
    end
  end
end
