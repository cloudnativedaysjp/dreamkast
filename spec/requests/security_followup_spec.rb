require 'rails_helper'

RSpec.describe('セキュリティ追加対応', type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let(:user) { create(:user) }

  def login_as(user, roles: [])
    auth = { info: { email: user.email }, extra: { raw_info: { sub: user.sub, email_verified: true, 'https://cloudnativedays.jp/roles' => roles } } }
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(auth))
  end

  describe '廃止済みチャット' do
    it '未認証でメッセージを作成できるChatChannelが存在しない' do
      expect(Object.const_defined?(:ChatChannel)).to(be(false))
    end

    it '管理画面のチャットページを提供しない' do
      login_as(user, roles: ['CNDT2020-Admin'])
      get "/#{conference.abbr}/admin/chat"
      expect(response).to(have_http_status(:not_found))
    end
  end

  describe 'プロフィール更新' do
    let!(:profile) { create(:alice, conference:, user:) }

    before { login_as(user) }

    it 'ユーザーのsub・emailや所属イベントを書き換えられない' do
      other_conference = create(:cndo2021)
      put "/#{conference.abbr}/profiles/#{profile.id}", params: {
        profile: {
          company_postal_code: '1010001',
          company_tel: '0312345678',
          department: '更新後',
          sub: 'google-oauth2|victim',
          email: 'victim@example.com',
          conference_id: other_conference.id
        }
      }

      expect(response).to(have_http_status(:found))
      expect(profile.reload.department).to(eq('更新後'))
      expect(profile.conference_id).to(eq(conference.id))
      expect(user.reload.sub).not_to(eq('google-oauth2|victim'))
      expect(user.email).not_to(eq('victim@example.com'))
    end
  end

  describe 'セッション資料URL' do
    let!(:talk) { create(:talk1) }

    it 'javascriptスキームのURLを保存できない' do
      expect(talk.update(document_url: 'javascript:alert(1)')).to(be(false))
      expect(talk.errors[:document_url]).to(be_present)
    end

    it 'http/httpsのURLは保存できる' do
      expect(talk.update(document_url: 'https://speakerdeck.com/example/slide')).to(be(true))
    end

    it '既存の不正なURLが残っていても他の項目は更新できる' do
      talk.update_column(:document_url, 'javascript:alert(1)')
      expect(talk.reload.update(title: '更新後')).to(be(true))
    end

    it '表示用URLはhttp/https以外を返さない' do
      talk.update_column(:document_url, 'javascript:alert(1)')
      expect(talk.reload.safe_document_url).to(be_nil)
    end

    it 'スポンサーセッションのフォームでも不正なURLを拒否する' do
      form = SponsorSessionForm.new({ document_url: 'javascript:alert(1)' }, conference:)
      expect(form).to(be_invalid)
      expect(form.errors[:document_url]).to(be_present)
    end

    it '公開APIは不正なURLを返さない' do
      talk.update_column(:document_url, 'javascript:alert(1)')
      get "/api/v1/talks/#{talk.id}"
      expect(JSON.parse(response.body)['documentUrl']).to(eq(''))
    end
  end

  describe 'CSVエクスポート' do
    it '数式として解釈される値をエスケープする' do
      talk = create(:talk1, title: '=HYPERLINK("https://evil.example","x")')
      csv = CSV.parse(Talk.export_csv(conference, [talk]), headers: true)
      expect(csv.first['title']).to(eq(%q('=HYPERLINK("https://evil.example","x"))))
    end
  end
end
