require 'rails_helper'

describe Api::V1::ChatMessagesController, type: :request do
  subject(:session) do
    {
      userinfo: {
        info: {
          email: 'alice@example.com',
          extra: { sub: 'alice' }
        },
        extra: {
          raw_info: {
            sub: 'alice',
            'https://cloudnativedays.jp/roles' => roles
          }
        }
      }
    }
  end

  describe 'PUT /api/v1/chat_message/:id' do
    describe 'update own chat message' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(info: { email: alice.email }))
        create(:talk1)
        create(:message_from_alice, profile: alice)
      end
      let!(:cndt2020) { create(:cndt2020) }
      let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }

      it 'confirm json schema' do
        put '/api/v1/chat_messages/1', params: { eventAbbr: 'cndt2020', body: 'hogehoge' }
        expect(response).to(have_http_status(:no_content))
        assert_response_schema_confirm
      end

      it 'succeed request' do
        put '/api/v1/chat_messages/1', params: { eventAbbr: 'cndt2020', body: 'hogehoge' }
        expect(response.status).to(eq(204))
      end
    end
  end

  describe 'update others chat message' do
    before do
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(info: { email: alice.email }))
      create(:talk1, conference: cndt2020)
    end
    let!(:cndt2020) { create(:cndt2020) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:bob) { create(:bob, :on_cndt2020) }
    let!(:msg) { create(:message_from_bob, profile: bob) }

    it 'confirm json schema' do
      put "/api/v1/chat_messages/#{msg.id}", params: { eventAbbr: 'cndt2020', body: 'hogehoge' }
      expect(response).to(have_http_status(:forbidden))
      assert_response_schema_confirm
    end

    it 'succeed request' do
      put "/api/v1/chat_messages/#{msg.id}", params: { eventAbbr: 'cndt2020', body: 'hogehoge' }
      expect(response.status).to(eq(403))
    end
  end
end
