require 'rails_helper'

describe TalksController, type: :request do
  subject(:session) { {userinfo: {info: {email: "foo@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa", "https://cloudnativedays.jp/roles" => roles}}} } }
  let(:roles) { [] }

  describe "GET /cndt2020/talks/:id" do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
      create(:track1)
      create(:track2)
      create(:track3)
      create(:track4)
      create(:track5)
      create(:track6)
      create(:talk_category1)
      create(:talk_difficulties1)
    end
    let!(:talk1) { create(:talk1) }
    let!(:talk2) { create(:talk2) }

    describe 'not logged in' do
      it "returns a success response" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include talk1.abstract
        expect(response.body).to include talk1.title
      end
    end


    describe 'logged in' do
      before do
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      it "returns a success response with form" do
        get '/cndt2020/talks/2'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'タイムテーブル'
        expect(response.body).to include talk2.title
      end
    end
  end
end