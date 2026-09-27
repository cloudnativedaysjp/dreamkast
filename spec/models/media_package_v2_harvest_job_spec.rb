require 'rails_helper'

RSpec.describe(MediaPackageV2HarvestJob, type: :model) do
  let!(:conference) { create(:cndt2020) }
  let!(:talk) { create(:talk1, conference:) }
  let(:streaming) { create(:streaming, status: 'created', conference:, track: conference.tracks.first) }
  let(:channel_group) { create(:media_package_v2_channel_group, streaming:) }
  let(:channel) { create(:media_package_v2_channel, streaming:, channel_group:) }
  let(:archive_origin_endpoint) { create(:media_package_v2_archive_origin_endpoint, streaming:, channel:) }
  let(:client) { Aws::MediaPackageV2::Client.new(stub_responses: true) }
  let(:start_time) { Time.zone.parse('2020-09-08T12:00:00+09:00') }
  let(:end_time) { Time.zone.parse('2020-09-08T12:40:00+09:00') }
  let(:harvest_job) do
    create(:media_package_v2_harvest_job, conference:, talk:, archive_origin_endpoint:, start_time:, end_time:)
  end

  # SDK はスタブのレスポンスも検証するため、必須項目を埋めた値を返す
  def harvest_job_response(status)
    {
      channel_group_name: 'g', channel_name: 'c', origin_endpoint_name: 'o', harvest_job_name: 'job', status:,
      arn: 'arn:aws:mediapackagev2:us-west-2:123456789012:channelGroup/g/channel/c/originEndpoint/o/harvestJob/job',
      created_at: Time.current, modified_at: Time.current,
      destination: { s3_destination: { bucket_name: 'bucket', destination_path: 'path' } },
      harvested_manifests: { hls_manifests: [{ manifest_name: 'index' }] },
      schedule_configuration: { start_time:, end_time: }
    }
  end

  before do
    allow_any_instance_of(described_class).to(receive(:media_package_v2_client).and_return(client))
  end

  describe 'validation' do
    it 'is invalid when end_time is not after start_time' do
      job = described_class.new(conference:, talk:, archive_origin_endpoint:, start_time: end_time, end_time: start_time)
      expect(job).not_to(be_valid)
      expect(job.errors[:end_time]).to(be_present)
    end
  end

  describe '#create_aws_resource' do
    before do
      client.stub_responses(:create_harvest_job, harvest_job_response('QUEUED'))
    end

    it 'creates a harvest job from the archive origin endpoint and stores the destination' do
      harvest_job.create_aws_resource

      params = client.api_requests.last[:params]
      expect(params[:origin_endpoint_name]).to(end_with('_archive'))
      expect(params[:harvested_manifests]).to(eq(hls_manifests: [{ manifest_name: 'index' }]))
      expect(params[:schedule_configuration][:start_time]).to(eq(start_time))
      expect(params[:schedule_configuration][:end_time]).to(eq(end_time))
      expect(params[:destination][:s3_destination][:destination_path]).to(eq("mediapackage/cndt2020/talks/#{talk.id}/#{harvest_job.id}"))

      harvest_job.reload
      expect(harvest_job.harvest_job_name).to(eq('job'))
      expect(harvest_job.status).to(eq('QUEUED'))
      expect(harvest_job.video_url).to(end_with("/mediapackage/cndt2020/talks/#{talk.id}/#{harvest_job.id}/index.m3u8"))
    end
  end

  describe '#refresh_status' do
    it 'updates status while the job is running' do
      harvest_job.update!(harvest_job_name: 'job', status: 'IN_PROGRESS')
      client.stub_responses(:get_harvest_job, harvest_job_response('COMPLETED'))

      harvest_job.refresh_status
      expect(harvest_job.reload.status).to(eq('COMPLETED'))
    end

    it 'does not call the API after the job finished' do
      harvest_job.update!(harvest_job_name: 'job', status: 'COMPLETED')
      harvest_job.refresh_status
      expect(client.api_requests).to(be_empty)
    end

    it 'keeps the stored status when the job record has expired' do
      harvest_job.update!(harvest_job_name: 'job', status: 'IN_PROGRESS')
      client.stub_responses(:get_harvest_job, 'NotFoundException')

      harvest_job.refresh_status
      expect(harvest_job.reload.status).to(eq('IN_PROGRESS'))
    end
  end
end
