require 'rails_helper'

RSpec.describe('ApplicationController', type: :request) do
  describe 'GET /not/found.html' do
    it 'returns 404 Not Found' do
      get '/not/found.html'
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('404'))
    end
  end

  describe 'GET /not/found.txt' do
    it 'returns 404 Not Found' do
      get '/not/found.txt'
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('404'))
    end
  end
end
