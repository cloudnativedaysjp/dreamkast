require 'rails_helper'

describe Api::V1::Talks::VideoRegistrationController, type: :request do
  # subject(:session) do
  #   {
  #     userinfo: {
  #       info: {
  #         email: 'alice@example.com',
  #         extra: { sub: 'alice' }
  #       },
  #       extra: {
  #         raw_info: {
  #           sub: 'alice',
  #           'https://cloudnativedays.jp/roles' => roles
  #         }
  #       }
  #     }
  #   }
  # end

  describe 'GET /api/v1/talks/:id/video_registration' do
    describe 'get video_registration' do
      let!(:cndt2020) { create(:cndt2020) }
      before do
        create(:talk1)
        create(:video_registration)
      end

      it 'confirm json schema' do
        get '/api/v1/talks/1/video_registration'
        expect(response).to(have_http_status(:ok))
        assert_response_schema_confirm
      end
    end
  end

  describe 'PUT /api/v1/talks/:id/video_registration' do
    let!(:cndt2020) { create(:cndt2020) }
    before do
      create(:talk1)
    end

    describe 'create newly' do
      it 'return OK when put url' do
        put '/api/v1/talks/1/video_registration', params: { url: 'https://' }, as: :json
        expect(response).to(have_http_status(:ok))
      end

      it 'return OK when put status and statistics' do
        put '/api/v1/talks/1/video_registration', params: { status: 'submitted', statistics: { foo: 'bar' } }, as: :json
        expect(response).to(have_http_status(:ok))
      end

      it 'return 400 when put url, status and statistics' do
        put '/api/v1/talks/1/video_registration', params: { url: 'https://', status: 'submitted', statistics: { foo: 'bar' } }, as: :json
        expect(response).to(have_http_status(400))
      end
    end

    describe 'update' do
      before do
        create(:video_registration)
      end

      it 'return OK when put url' do
        put '/api/v1/talks/1/video_registration', params: { url: 'https://' }, as: :json
        expect(response).to(have_http_status(:ok))
      end

      it 'return OK when put status and statistics' do
        put '/api/v1/talks/1/video_registration', params: { status: 'submitted', statistics: { foo: 'bar' } }, as: :json
        expect(response).to(have_http_status(:ok))
      end

      it 'return 400 when put url, status and statistics' do
        put '/api/v1/talks/1/video_registration', params: { url: 'https://', status: 'submitted', statistics: { foo: 'bar' } }, as: :json
        expect(response).to(have_http_status(400))
      end
    end
  end
end
