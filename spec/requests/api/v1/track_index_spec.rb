require 'rails_helper'

describe TalksController, type: :request do
  describe 'GET /api/v1/tracks' do
    before do
      create(:cndt2020)
      create(:talk1)
      create(:talk2)
    end

    it 'confirm json schema' do
      get '/api/v1/tracks?eventAbbr=cndt2020'
      assert_response_schema_confirm(200)
    end

    it 'succeed request' do
      get '/api/v1/tracks?eventAbbr=cndt2020'
      expect(response.status).to(eq(200))
    end

    it 'returns 404 when eventAbbr is missing' do
      get '/api/v1/tracks'
      expect(response.status).to(eq(404))
    end

    it 'returns 404 when eventAbbr does not match any conference' do
      get '/api/v1/tracks?eventAbbr=not_found'
      expect(response.status).to(eq(404))
    end
  end
end
