require 'rails_helper'

describe TracksController, type: :request do
  describe 'GET /api/v1/tracks/{trackId}' do
    before do
      create(:cndt2021)
      create(:cndt2021_track)
      create(:cndt2021_talk1)
      create(:cndt2021_viewer_count)
    end

    it 'confirm json schema' do
      get '/api/v1/tracks/11/viewer_count'
      expect(response).to(have_http_status(:ok))
      assert_response_schema_confirm
    end

    it 'successed request' do
      get '/api/v1/tracks/11/viewer_count'
      expect(response.status).to(eq(200))
    end

    it 'return 404' do
      get '/api/v1/tracks/200/viewer_count'
      expect(response.status).to(eq(404))
    end
  end
end
