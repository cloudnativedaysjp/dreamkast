require 'rails_helper'

describe Api::V1::ChatMessagesController, type: :request do
  subject(:session) {
    {
      userinfo: {
        info: {
          email: "alice@example.com",
          extra: {sub: "alice"}
        },
        extra: {
          raw_info: {
            sub: "alice",
            "https://cloudnativedays.jp/roles" => roles
          }
        }
      }
    }
  }

  describe 'GET /api/v1/chat_messages' do
    before do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: alice.email}})
      create(:talk1)
      create(:message_from_alice, profile: alice)
    end

    let!(:cndt2020) { create(:cndt2020) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020)}

    it 'succeed request' do
      get '/api/v1/chat_messages?eventAbbr=cndt2020&roomId=1&roomType=talk'
      expect(response).to have_http_status :ok
      expect(response.status).to eq 200
    end

    it 'confirm json schema' do
      get '/api/v1/chat_messages?eventAbbr=cndt2020&roomId=1&roomType=talk'
      assert_response_schema_confirm
    end
  end
end
