require 'rails_helper'

describe TalksController, type: :request do
  describe 'PUT /api/v1/talk/1' do
    before do
      create(:cndt2020)
      create(:talk1)
      create(:talk2)
      create(:video, :off_air)
      create(:video, :on_air, :talk2)
    end

    context 'update without JWT token' do
      it 'return 401 and video.on_air does not be changed' do
        put '/api/v1/talks/1', params: { on_air: true }, as: :json, headers: headers
        expect(response).to(have_http_status(:unauthorized))
        expect(Talk.find(1).video.on_air).to(eq(false))
      end
    end

    context 'update' do
      before do
        allow(JsonWebToken).to(receive(:verify).and_return(claim))
      end

      it 'return ok' do
        put '/api/v1/talks/1', params: { on_air: true }, as: :json, headers: headers
        expect(response).to(have_http_status(:ok))
      end
    end
  end
end
