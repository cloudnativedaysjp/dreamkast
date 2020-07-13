require 'rails_helper'

describe TimetableController, type: :request do
  describe "GET #index" do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
      create(:talk_category1)
      create(:talk_difficulties1)
    end

    let!(:talk1) { create(:talk1) }
    let!(:talk2) { create(:talk2) }

    describe 'not logged in' do
      it "returns a success response without form" do
        get '/cndt2020/timetables'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to_not include '<form action="profiles/talks"'
        expect(response.body).to include talk1.title
        expect(response.body).to include talk2.title
      end
    end


    describe 'logged in' do
      before do
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return(userinfo: {info: {email: "foo@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa"}}})
      end

      it "returns a success response with form" do
        get '/cndt2020/timetables'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include '<form action="profiles/talks"'
        expect(response.body).to include talk1.title
        expect(response.body).to include talk2.title
      end
    end
  end
end