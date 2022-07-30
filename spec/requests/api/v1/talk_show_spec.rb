require 'rails_helper'

describe TalksController, type: :request do
  describe 'GET /api/v1/talks' do
    describe 'talk belongs to conference_day' do
      before do
        create(:cndt2020)
        create(:talk1)
        create(:talk2)
      end

      it 'confirm json schema' do
        get '/api/v1/talks/1'
        expect(response).to(have_http_status(:ok))
        assert_response_schema_confirm
      end

      it 'successed request' do
        get '/api/v1/talks/1'
        expect(response.status).to(eq(200))
      end
    end

    describe 'talk doesn\'t belong to conference_day' do
      before do
        create(:cndt2020)
        create(:talk1, conference_day_id: nil)
      end

      it 'confirm json schema' do
        get '/api/v1/talks/1'
        expect(response).to(have_http_status(:ok))
        assert_response_schema_confirm

        expect(response.body).to(include('talk1'))
        expect(response.body).to(include('"conferenceDayId":null'))
        expect(response.body).to(include('"conferenceDayDate":null'))
      end
    end
  end
end
