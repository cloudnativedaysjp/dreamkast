require 'rails_helper'

# 脱Redis 対応（redis / redis-session-store を
# solid_cable / activerecord-session_store へ置き換え）が
# 正しく機能していることを保証するテスト。
RSpec.describe('脱Redis (solid_cable / activerecord-session_store)') do
  describe 'セッションストア (activerecord-session_store)', type: :request do
    it 'session_store が ActiveRecord ベースに設定されている' do
      expect(Rails.application.config.session_store).to(eq(ActionDispatch::Session::ActiveRecordStore))
    end

    context 'Auth0 コールバックでログインした場合' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
          'provider' => 'auth0',
          'uid' => 'google-oauth2|alice',
          'info' => { 'email' => 'alice@example.com' },
          'extra' => { 'raw_info' => { 'sub' => 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => '' } }
        )
      end

      after do
        OmniAuth.config.mock_auth[:auth0] = nil
        OmniAuth.config.test_mode = false
      end

      it 'セッションが Redis ではなく DB(sessions テーブル) へ永続化される' do
        # Auth0 のコールバックは request.env['omniauth.auth'] を session[:userinfo] へ保存する。
        expect do
          get('/auth/auth0/callback')
        end.to(change(ActiveRecord::SessionStore::Session, :count).by(1))

        # コールバック後はトップへリダイレクトされる。
        expect(response).to(have_http_status(:found))

        # セッション本体が DB(sessions.data) に書き込まれていることを確認する。
        stored = ActiveRecord::SessionStore::Session.last
        expect(stored.data.dig('userinfo', 'info', 'email')).to(eq('alice@example.com'))
      end
    end
  end

  describe 'Action Cable (solid_cable)' do
    it 'development / production の adapter が solid_cable に設定されている' do
      %w[development production].each do |env|
        config = Rails.application.config_for(:cable, env:)
        expect(config[:adapter]).to(eq('solid_cable'))
      end
    end

    it 'test 環境は test アダプタを使う（外部依存なし）' do
      config = Rails.application.config_for(:cable, env: 'test')
      expect(config[:adapter]).to(eq('test'))
    end
  end

  describe 'Redis 依存の不在' do
    it 'redis / redis-session-store gem が bundle に含まれていない' do
      locked_gems = Bundler.locked_gems.specs.map(&:name)
      expect(locked_gems).not_to(include('redis'))
      expect(locked_gems).not_to(include('redis-session-store'))
    end
  end
end
