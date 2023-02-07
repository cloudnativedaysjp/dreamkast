require 'rails_helper'

describe Api::V1::SpeakersController, type: :request do
  describe 'GET /api/v1/speakers?eventAbbr=cndt2020' do
    describe 'talk belongs to conference_day' do
      before do
        create(:cndt2020)
        create(:speaker_alice)
        create(:speaker_bob)
      end

      it 'confirm json schema' do
        get '/api/v1/speakers?eventAbbr=cndt2020'
        expect(response).to(have_http_status(:ok))
        assert_response_schema_confirm
        expect(response.body).to(include('Alice'))
        expect(response.body).to(include('Bob'))
      end

      it 'successes request' do
        get '/api/v1/speakers?eventAbbr=cndt2020'
        expect(response.status).to(eq(200))
      end
    end
  end
end
