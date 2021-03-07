require 'rails_helper'

describe Api::V1::ChatMessagesController, type: :request do
  subject(:session) {
    {
      userinfo: {
        info: {
          email: "foo@example.com",
          extra: {sub: "aaa"}
        },
        extra: {
          raw_info: {
            sub: "aaa",
            "https://cloudnativedays.jp/roles" => roles
          }
        }
      }
    }
  }

  describe 'PUT /api/v1/chat_message/:id' do
    describe 'update own chat message' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
        create(:cndt2020)
        create(:alice)
        create(:talk1)
        create(:message_from_alice)
      end

      it 'confirm json schema' do
        put '/api/v1/chat_messages/1', params: {"eventAbbr": "cndt2020", "body": "hogehoge"}
        expect(response).to have_http_status :no_content
        assert_response_schema_confirm
      end

      it 'succeed request' do
        put '/api/v1/chat_messages/1', params: {"eventAbbr": "cndt2020", "body": "hogehoge"}
        expect(response.status).to eq 204
      end
    end
  end

  describe 'update others chat message' do
    before do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      create(:cndt2020)
      create(:alice)
      create(:bob)
      create(:talk1)
      create(:message_from_bob)
    end

    it 'confirm json schema' do
      put '/api/v1/chat_messages/2', params: {"eventAbbr": "cndt2020", "body": "hogehoge"}
      expect(response).to have_http_status :forbidden
      assert_response_schema_confirm
    end

    it 'succeed request' do
      put '/api/v1/chat_messages/2', params: {"eventAbbr": "cndt2020", "body": "hogehoge"}
      expect(response.status).to eq 403
    end
  end
end
