require 'rails_helper'

describe TalksController, type: :request do
  describe 'GET /api/v1/tracks/{trackId}' do
    before do
      create(:cndt2020)
      create(:talk1)
      create(:talk2)
    end

    it 'confirm json schema' do
      get '/api/v1/tracks/1'
      assert_response_schema_confirm(200)
    end

    it 'successed request' do
      get '/api/v1/tracks/1'
      expect(response.status).to(eq(200))
    end
  end
end
