require 'rails_helper'

describe ContentsController, type: :request do

  describe "GET #index" do
    before do
      create(:cndt2020)
    end

    it "returns a success response with contents (sub event) list" do
      get '/cndt2020/contents'
      expect(response).to be_successful
      expect(response).to have_http_status '200'
      expect(response.body).to include '併設イベント'
    end
  end

end
