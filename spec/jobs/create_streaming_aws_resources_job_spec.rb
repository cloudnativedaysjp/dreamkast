require 'rails_helper'

RSpec.describe(CreateStreamingAwsResourcesJob, type: :job) do
  include ActiveJob::TestHelper

  describe '' do
    before do
      allow_any_instance_of(CreateStreamingAwsResourcesJob).to(receive(:create_media_package_v2_resources) { true })
      allow_any_instance_of(CreateStreamingAwsResourcesJob).to(receive(:create_media_package_resources) { true })
      allow_any_instance_of(CreateStreamingAwsResourcesJob).to(receive(:create_media_live_resources) { true })
    end

    let!(:conference) { create(:cndt2020) }
    let(:streaming) { create(:streaming, status: 'deleted', conference:, track: conference.tracks.first) }

    subject(:job) { CreateStreamingAwsResourcesJob.perform_later(streaming) }

    it 'queues the job' do
      expect { job }.to(change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size)
        .by(1)
        .and(have_enqueued_job(described_class).with(streaming)))
    end

    context 'when performing job' do
      it 'updates the my_model field' do
        perform_enqueued_jobs { job }
        expect(streaming.reload.status).to(eq('created'))
      end
    end
  end
end
