require 'rails_helper'

describe ContentsController, type: :request do
  describe 'GET #o11y' do
    before do
      create(:cndt2020)
    end

    it 'returns a success response' do
      get '/cndt2020/o11y'
      expect(response).to(be_successful)
    end
  end

  describe 'GET removed content pages' do
    before do
      create(:cndt2020)
    end

    %w[discussion hands-on job-board community_lt yurucafe stamprally].each do |page|
      it "returns 404 for #{page}" do
        get "/cndt2020/#{page}"
        expect(response).to(have_http_status('404'))
      end
    end
  end
end
