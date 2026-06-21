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
    before do
      allow_any_instance_of(described_class).to(receive(:convert_hls_to_mp4) { '/tmp/dummy.mp4' })
      allow_any_instance_of(described_class).to(receive(:upload_to_youtube) { 'yt-video-id' })
      allow_any_instance_of(described_class).to(receive(:cleanup_tmp_files) { true })
    end

    context 'on success' do
      it 'uploads and marks the video as uploaded' do
        perform_enqueued_jobs { described_class.perform_later(video) }
        video.reload
        expect(video).to(be_uploaded)
        expect(video.youtube_video_id).to(eq('yt-video-id'))
        expect(video.youtube_uploaded_at).to(be_present)
      end
    end

    context 'on error' do
      before do
        allow_any_instance_of(described_class).to(receive(:convert_hls_to_mp4).and_raise('boom'))
      end

      it 'marks the video as failed and records the error' do
        perform_enqueued_jobs { described_class.perform_later(video) }
        video.reload
        expect(video).to(be_failed)
        expect(video.youtube_upload_error).to(eq('boom'))
      end
    end

    context 'when already uploaded (idempotency)' do
      let(:video) { create(:video, :youtube_uploaded, talk:) }

      it 'skips conversion and upload' do
        expect_any_instance_of(described_class).not_to(receive(:convert_hls_to_mp4))
        expect_any_instance_of(described_class).not_to(receive(:upload_to_youtube))
        perform_enqueued_jobs { described_class.perform_later(video) }
      end
    end
  end
end
