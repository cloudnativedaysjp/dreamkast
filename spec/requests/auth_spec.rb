require 'rails_helper'

RSpec.describe('Auth', type: :request) do
  describe 'POST /cndt2020/auth/auth0' do
    it 'redirect /auth/auth0' do
      post '/cndt2020/auth/auth0'
      expect(response).to(redirect_to('/auth/auth0'))
    end
  end
end
