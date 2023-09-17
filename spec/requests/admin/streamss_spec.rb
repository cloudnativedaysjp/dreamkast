require 'rails_helper'

describe Admin::SpeakersController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }

  before do
    conference = create(:cndt2020)
    streaming = create(:streaming, status: 'created', conference:, track: conference.tracks.first)
    channel_group = create(:media_package_v2_channel_group, streaming:)
    channel = create(:media_package_v2_channel, streaming:, channel_group:)
    create(:media_package_v2_origin_endpoint, streaming:, channel:)

    [MediaLiveChannel, MediaLiveInput, MediaPackageChannel, MediaPackageOriginEndpoint, MediaPackageV2Channel, MediaPackageV2OriginEndpoint].each do |klass|
      allow_any_instance_of(klass).to(receive(:aws_resource) do |*_arg|
        nil
      end)
    end
  end

  context 'user logged in' do
    before do
      Streaming.define_method(:original, Streaming.instance_method(:playback_url))
      allow_any_instance_of(Streaming).to(receive(:playback_url) do |*_arg|
        'https://example.cloudnativedays.jp/index.m3u8'
      end)

      ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
        if arg[1] == :userinfo
          session[:userinfo]
        else
          arg[0].send(:original, arg[1])
        end
      end)

      allow_any_instance_of(MediaLiveChannel).to(receive(:state) do |*_arg|
        'IDLE'
      end)
    end

    describe 'GET :event/admin/streamings#index' do
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
  end
end
