require 'rails_helper'

RSpec.describe(UploadArchiveToYoutubeJob, type: :job) do
  include ActiveJob::TestHelper

  let!(:conference) { create(:cndt2020) }
  let!(:talk) { create(:talk1) }
  let(:video) { create(:video, talk:) }

  describe 'enqueue' do
    subject(:job) { described_class.perform_later(video) }

    it 'queues the job' do
      expect { job }.to(change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
        .and(have_enqueued_job(described_class).with(video)))
    end
  end

  describe '#perform' do
    it 'delegates to Youtube::ArchiveUploader#process!' do
      uploader = instance_double(Youtube::ArchiveUploader, process!: :started)
      allow(Youtube::ArchiveUploader).to(receive(:new).with(video).and_return(uploader))
      perform_enqueued_jobs { described_class.perform_later(video) }
      expect(uploader).to(have_received(:process!))
    end
  end
end
