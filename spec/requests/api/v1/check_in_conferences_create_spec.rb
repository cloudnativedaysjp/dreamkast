require 'rails_helper'

describe Api::V1::CheckInConferencesController, type: :request do
  describe 'POST /api/v1/check_in_conferences' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:talk) { create(:talk1) }

    context 'create without JWT token' do
      it 'return 401' do
        post('/api/v1/check_in_conferences', params: { eventAbbr: 'cndt2020', profileId: alice.id, check_in_timestamp: 1_715_483_605 }, as: :json)
        expect(response).to(have_http_status(:unauthorized))
      end
    end

    context 'create' do
      before do
        allow(JsonWebToken).to(receive(:verify).and_return(claim))
      end

      it 'return ok' do
        post('/api/v1/check_in_conferences', params: { eventAbbr: 'cndt2020', profileId: alice.id, check_in_timestamp: 1_715_483_605 }, as: :json)
        expect(response).to(have_http_status(:created))
      end
    end
  end
end