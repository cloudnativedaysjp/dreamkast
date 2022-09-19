require 'rails_helper'

describe Api::V1::ConferencesController, type: :request do
  describe 'GET /api/v1/events' do
    context 'system has two conferences' do
      before do
        create(:cndt2020)
        create(:cndo2021)
      end

      it 'confirm json schema' do
        get '/api/v1/events'
        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include('cndt2020'))
        expect(response.body).to(include('cndo2021'))
        assert_response_schema_confirm
      end
    end
  end
end
