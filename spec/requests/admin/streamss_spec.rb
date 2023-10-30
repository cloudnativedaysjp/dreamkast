require 'rails_helper'

describe Admin::SpeakersController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }
  let!(:conference) { create(:cndt2020) }

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

  describe 'GET :event/admin/streamings#index' do
    before do
      streaming = create(:streaming, status: 'created', conference:, track: conference.tracks.first)
      channel_group = create(:media_package_v2_channel_group, streaming:)
      channel = create(:media_package_v2_channel, streaming:, channel_group:)
      create(:media_package_v2_origin_endpoint, streaming:, channel:)

      [MediaLiveChannel, MediaLiveInput, MediaPackageChannel, MediaPackageOriginEndpoint, MediaPackageV2Channel, MediaPackageV2OriginEndpoint].each do |klass|
        allow_any_instance_of(klass).to(receive(:aws_resource) do |*_arg|
          nil
        end)
      end

      Streaming.define_method(:original, Streaming.instance_method(:playback_url))
      allow_any_instance_of(Streaming).to(receive(:playback_url) do |*_arg|
        'https://example.cloudnativedays.jp/index.m3u8'
      end)

      allow_any_instance_of(MediaLiveChannel).to(receive(:state) do |*_arg|
        'IDLE'
      end)
    end

    it 'returns a success response' do
      get admin_streamings_path(event: 'cndt2020')
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'returns a success response with streams' do
      get admin_streamings_path(event: 'cndt2020')
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))

      expect(response.body).to(include('created'))
      expect(response.body).to(include('https://example.cloudnativedays.jp/index.m3u8'))
    end
  end

  describe 'POST :event/admin/streamings' do
    before do
      allow_any_instance_of(CreateStreamingAwsResourcesJob).to(receive(:perform) { true })
    end
    it 'returns a success response' do
      post admin_streamings_path(event: 'cndt2020'), params: { streaming: { conference_id: conference.id, track_id: conference.tracks.first.id, status: 'creating' } }
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response.body).to(redirect_to('/cndt2020/admin/streamings'))
    end
  end

  describe 'POST :event/admin/delete_aws_resources' do
    before do
      allow_any_instance_of(CreateStreamingAwsResourcesJob).to(receive(:perform) { true })
    end

    let(:streaming) { create(:streaming, status: 'created', conference:, track: conference.tracks.first) }

    it 'returns a success response' do
      post admin_delete_aws_resources_path(id: streaming.id, event: 'cndt2020')
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response.body).to(redirect_to('/cndt2020/admin/streamings'))
    end
  end
end
