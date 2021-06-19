require 'rails_helper'

describe EventController, type: :request do
  subject(:session) { {userinfo: {info: {email: "alice@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => roles}}}} }
  let(:roles) { [] }

  describe "GET event#show" do
    before do
      create(:cndt2020)
    end

    describe 'not logged in' do
      it "returns a success response with event top page" do
        get '/cndt2020'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'CloudNative Days Tokyo 2020'
        expect(response.body).to include 'スピーカーとしてエントリー'
      end

      it "returns a success response with privacy policy" do
        get '/cndt2020/privacy'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'This is Privacy Policy'
      end

      it "returns a success response with code of conduct" do
        get '/cndt2020/coc'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include '行動規範'
      end
    end

    describe 'logged in' do
      describe 'not registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
        end

        it "returns a success response with event top page" do
          get '/cndt2020'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'CloudNative Days Tokyo 2020'
          expect(response.body).to include 'スピーカーとしてエントリー'
        end
      end

      describe 'registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
          create(:speaker_alice)
        end

        it "returns a success response with event top page" do
          get '/cndt2020'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'CloudNative Days Tokyo 2020'
          expect(response.body).to include 'スピーカーダッシュボード'
        end
      end
    end
  end
end
