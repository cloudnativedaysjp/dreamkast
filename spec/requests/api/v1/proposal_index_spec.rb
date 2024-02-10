require 'rails_helper'

describe Api::V1::ProposalsController, type: :request do
  describe 'GET /api/v1/proposals' do
    before do
      create(:cndt2020)
      create(:talk1, :accepted)
    end

    it 'confirm json schema' do
      get '/api/v1/proposals?eventAbbr=cndt2020'
      expect(response).to(have_http_status(:ok))
      assert_response_schema_confirm
    end

    it 'succeed request' do
      get '/api/v1/proposals?eventAbbr=cndt2020'
      expect(response.status).to(eq(200))
    end

    context 'return only Session type' do
      before do
        create(:talk2, :accepted)
        create(:sponsor_session, :accepted)
        create(:keynote_session, :accepted)
      end

      it 'return only session talk' do
        get '/api/v1/proposals?eventAbbr=cndt2020'
        expect(response).to(have_http_status(:ok))
        expect(response.parsed_body.length).to(eq 2)
      end
    end
  end
end
