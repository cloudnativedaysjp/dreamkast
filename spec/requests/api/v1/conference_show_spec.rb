require 'rails_helper'

describe Api::V1::ConferencesController, type: :request do
  describe 'GET /api/v1/events/cndt2020' do
    context 'request id 1' do
      before do
        create(:cndt2020)
        create(:cndo2021)
      end

      it 'should have valid conference' do
        get '/api/v1/events/cndt2020'
        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include('cndt2020'))
        expect(response.body).not_to(include('cndo2021'))
        assert_response_schema_confirm
      end
    end
  end
end
