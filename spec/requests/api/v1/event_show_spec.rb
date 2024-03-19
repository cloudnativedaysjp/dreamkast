require 'rails_helper'

describe EventController, type: :request do
  describe 'GET /api/v1/events/{eventId}' do
    before do
      create(:cndt2020)
    end

    it 'confirm json schema' do
      get '/api/v1/events/cndt2020'
      assert_response_schema_confirm(200)
    end

    it 'successed request' do
      get '/api/v1/events/cndt2020'
      expect(response.status).to(eq(200))
    end
  end
end
