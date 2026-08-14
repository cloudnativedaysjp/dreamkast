require 'rails_helper'

describe Admin::VideosController, type: :request do
  include ActiveJob::TestHelper

  subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }
  let!(:conference) { create(:cndt2020) }
  let!(:talk) { create(:talk1) }
  let!(:video) { create(:video, talk:, video_id: 'https://example.com/playlist.m3u8') }

  before do
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
      if arg[1] == :userinfo
        session[:userinfo]
      else
        arg[0].send(:original, arg[1])
      end
    end)
  end

  describe 'POST :event/admin/videos/:id/upload_to_youtube' do
    subject { post(upload_to_youtube_admin_video_path(video, event: 'cndt2020')) }

    context 'when user is admin' do
      it 'enqueues the upload job and redirects' do
        expect { subject }.to(have_enqueued_job(UploadArchiveToYoutubeJob).with(video))
        expect(response).to(have_http_status('302'))
      end
    end

    context 'when user is not logged in' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(nil))
      end

      it 'redirects to login and does not enqueue' do
        expect { subject }.not_to(have_enqueued_job(UploadArchiveToYoutubeJob))
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to("/auth/login?origin=/cndt2020/admin/videos/#{video.id}/upload_to_youtube"))
      end
    end
  end
end
