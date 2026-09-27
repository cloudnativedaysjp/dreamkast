require 'rails_helper'

RSpec.describe(MediaPackageV2ArchiveOriginEndpoint, type: :model) do
  let!(:conference) { create(:cndt2020) }
  let(:streaming) { create(:streaming, status: 'created', conference:, track: conference.tracks.first) }
  let(:channel_group) { create(:media_package_v2_channel_group, streaming:) }
  let(:channel) { create(:media_package_v2_channel, streaming:, channel_group:) }
  let(:endpoint) { create(:media_package_v2_archive_origin_endpoint, streaming:, channel:) }
  let(:client) { Aws::MediaPackageV2::Client.new(stub_responses: true) }

  before do
    allow_any_instance_of(described_class).to(receive(:media_package_v2_client).and_return(client))
  end

  describe '#create_aws_resource' do
    before do
      client.stub_responses(:get_origin_endpoint, 'NotFoundException')
      client.stub_responses(:create_origin_endpoint, { origin_endpoint_name: 'test_cndt2020_trackA_archive', channel_group_name: 'g', channel_name: 'c', container_type: 'TS' })
    end

    it 'creates an HLS endpoint that can be harvested for a week' do
      endpoint.create_aws_resource

      create_params = client.api_requests.find { |r| r[:operation_name] == :create_origin_endpoint }[:params]
      expect(create_params[:origin_endpoint_name]).to(end_with('_archive'))
      expect(create_params[:segment][:segment_duration_seconds]).to(eq(6))
      expect(create_params[:startover_window_seconds]).to(eq(604_800))
      expect(create_params[:hls_manifests]).to(contain_exactly(include(manifest_name: 'index')))

      policy_params = client.api_requests.find { |r| r[:operation_name] == :put_origin_endpoint_policy }[:params]
      statements = JSON.parse(policy_params[:policy])['Statement']
      harvester = statements.find { |s| s['Sid'] == 'AllowMediaPackageHarvestObjectAccess' }
      expect(harvester['Principal']).to(eq('Service' => 'mediapackagev2.amazonaws.com'))
      expect(harvester['Action']).to(contain_exactly('mediapackagev2:HarvestObject', 'mediapackagev2:GetObject'))

      expect(endpoint.reload.name).to(eq('test_cndt2020_trackA_archive'))
    end
  end
end
