require 'rails_helper'

describe TalksController, type: :request do
  describe 'GET /api/v1/talks' do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
      create(:talk1)
      create(:talk2)
      create(:talk3)
    end

    it 'confirm json schema' do
      get '/api/v1/talks?eventAbbr=cndt2020'
      expect(response).to have_http_status :ok
      assert_response_schema_confirm
      expect(response.body).to include "talk1"
      expect(response.body).to include "talk3"
    end

    it 'have all talks when it doesnt specify trackId' do
      get '/api/v1/talks?eventAbbr=cndt2020'
      expect(response.body).to include "talk1"
      expect(response.body).to include "talk3"
    end

    it 'only have talks belongs to track1 when it specify trackId=1' do
      get '/api/v1/talks?eventAbbr=cndt2020&trackId=1'
      expect(response.body).to include "talk1"
      expect(response.body).not_to include "talk3"
    end

    it 'successed request' do
      get '/api/v1/talks?eventAbbr=cndt2020'
      expect(response.status).to eq 200
    end
  end
end

