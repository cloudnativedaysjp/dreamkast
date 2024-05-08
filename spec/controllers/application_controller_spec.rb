require 'rails_helper'

RSpec.describe(ApplicationController, type: :controller) do
  describe '#current_user' do
    subject { controller.current_user }
    context 'when omniauth session does not exist' do
      it { is_expected.to(eq(nil)) }
    end

    context 'when omniauth session exists' do
      before do
        @userinfo = {
          info: { email: 'alice@example.com' },
          extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } }
        }
        session[:userinfo] = @userinfo
      end
      it { is_expected.to(eq(@userinfo)) }
    end
  end

  describe '#logged_in?' do
    subject { controller.logged_in? }
    context 'when logged in' do
      before do
        @userinfo = {
          info: { email: 'alice@example.com' },
          extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } }
        }
        session[:userinfo] = @userinfo
      end
      it { is_expected.to(eq(true)) }
    end

    context 'when not logged in' do
      it { is_expected.to(eq(false)) }
    end
  end
end
