require 'rails_helper'

describe Admin::ProfilesController, type: :request do
  let(:roles) { ['CNDT2020-Admin'] }
  let(:session) do
    {
      userinfo: {
        info: { email: 'alice@example.com' },
        extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } }
      }
    }
  end

  let!(:conference) { create(:cndt2020) }
  let!(:alice) do
    create(:alice, :on_cndt2020, last_name: '山田', first_name: '花子', last_name_kana: 'ヤマダ', first_name_kana: 'ハナコ')
  end
  let!(:bob) do
    create(:bob, :on_cndt2020, last_name: '佐藤', first_name: '太郎', last_name_kana: 'サトウ', first_name_kana: 'タロウ')
  end

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

  describe 'GET /:event/admin/profiles' do
    it '姓名の複数語で検索できる' do
      get admin_profiles_path(event: conference.abbr, q: '山田 花')

      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include(alice.email))
      expect(response.body).not_to(include(bob.email))
    end

    it 'かなで検索できる' do
      get admin_profiles_path(event: conference.abbr, q: 'サト')

      expect(response.body).to(include(bob.email))
      expect(response.body).not_to(include(alice.email))
    end

    it '登録メールアドレスで検索できる' do
      get admin_profiles_path(event: conference.abbr, q: 'bob@')

      expect(response.body).to(include(bob.email))
      expect(response.body).not_to(include(alice.email))
    end

    it 'SQL ワイルドカードを検索文字として扱う' do
      get admin_profiles_path(event: conference.abbr, q: '%')

      expect(response.body).not_to(include(alice.email))
      expect(response.body).not_to(include(bob.email))
    end
  end
end
