require 'rails_helper'

describe Api::V1::CheckInTalksController, type: :request do
  describe 'POST /api/v1/check_in_talks' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:talk) { create(:talk1) }

    context 'create without JWT token' do
      it 'return 401' do
        post('/api/v1/check_in_talks', params: { eventAbbr: 'cndt2020', talkId: talk.id, profileId: alice.id, timestamp: 1_715_483_605 }, as: :json)
        expect(response).to(have_http_status(:unauthorized))
      end
    end

    context 'create' do
      before do
        allow(JsonWebToken).to(receive(:verify).and_return(claim))
      end

      it 'return ok' do
        post('/api/v1/check_in_talks', params: { eventAbbr: 'cndt2020', talkId: talk.id, profileId: alice.id, timestamp: 1_715_483_605 }, as: :json)
        expect(response).to(have_http_status(:created))
      end
    end
  end
end
