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
    let!(:video) { create(:video) }

    describe 'not logged in' do
      it "returns a success response" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include talk1.abstract
        expect(response.body).to include talk1.title
      end

      it "doesn't includes vimeo iframe when site registered" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).not_to include "player.vimeo.com"
      end

      it "doesn't includes slido iframe" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).not_to include "sli.do"
      end
    end

    describe 'not logged in and site closed' do
      before do
        Conference.destroy_all
        create(:cndt2020_closed)
        allow_any_instance_of(Talk).to receive(:archived?).and_return(true)
      end
      it "includes vimeo iframe" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).to_not include "player.vimeo.com"
      end
    end

    describe 'not logged in and site opened' do
      before do
        Conference.destroy_all
        create(:cndt2020_opened)
      end
      it "doesn't includes vimeo iframe" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).not_to include "player.vimeo.com"
      end
    end

    describe 'logged in and not registerd' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /cndt2020/registration" do
        get '/cndt2020/talks/1'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020/registration'
      end
    end

    describe 'logged in and site registered' do
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

      it " doesn't includes vimeo iframe whatever video_published is true" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).not_to include "player.vimeo.com"
      end

      it "includes slido iframe if it has slido id" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).to include "sli.do"
      end

      it "includes twitter iframe if it not have slido id" do
        get '/cndt2020/talks/2'
        expect(response).to be_successful
        expect(response.body).to include "twitter-timeline"
      end
    end

    describe 'logged in and site opened' do
      before do
        Conference.destroy_all
        create(:cndt2020_opened)
        create(:cndo2021)
        create(:alice)
        create(:alice_cndo2021)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
        allow_any_instance_of(Talk).to receive(:archived?).and_return(true)
      end

      it " includes vimeo iframe if video_published is true" do
        get '/cndt2020/talks/1'
        expect(response).to be_successful
        expect(response.body).to include "player.vimeo.com"
      end

      it "doesn't includes vimeo iframe if video_published is false" do
        get '/cndt2020/talks/2'
        expect(response).to be_successful
        expect(response.body).not_to include "player.vimeo.com"
      end

      it "return 404 when you try to show talk that is not included conference" do
        get '/cndo2021/talks/1'
        expect(response).to_not be_successful
        expect(response).to have_http_status '404'
      end
    end
  end
end