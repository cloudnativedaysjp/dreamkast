require 'rails_helper'

RSpec.describe(Youtube::ArchiveUploader) do
  let!(:conference) { create(:cndt2020) }
  let!(:talk) { create(:talk1) }

  subject(:uploader) { described_class.new(video) }

  describe '#process!' do
    context 'when not_uploaded with an archive' do
      let(:video) { create(:video, talk:, video_id: 'https://example.com/playlist.m3u8') }

      before do
        allow(uploader).to(receive(:latest_harvest_job).and_return(double(s3_manifest_uri: 's3://bucket/key.m3u8')))
        allow(uploader).to(receive(:output_uri_prefix).and_return('s3://out/youtube/1/'))
        allow(uploader).to(receive(:create_media_convert_job).and_return('mcjob-1'))
      end

      it 'starts the MediaConvert job and moves to converting' do
        expect(uploader.process!).to(eq(:started))
        video.reload
        expect(video).to(be_converting)
        expect(video.media_convert_job_id).to(eq('mcjob-1'))
      end
    end

    context 'when converting' do
      let(:video) do
        create(:video, talk:, video_id: 'https://example.com/playlist.m3u8',
                       youtube_upload_status: :converting, media_convert_job_id: 'mcjob-1')
      end

      context 'and MediaConvert is still in progress' do
        before { allow(uploader).to(receive(:media_convert_job_status).and_return('PROGRESSING')) }

        it 'stays converting' do
          expect(uploader.process!).to(eq(:in_progress))
          expect(video.reload).to(be_converting)
        end
      end

      context 'and MediaConvert is complete' do
        before do
          allow(uploader).to(receive(:media_convert_job_status).and_return('COMPLETE'))
          allow(uploader).to(receive(:download_mp4).and_return('/tmp/x.mp4'))
          allow(uploader).to(receive(:upload_video_to_youtube).and_return('yt-id'))
          allow(uploader).to(receive(:cleanup_tmp_files))
        end

        it 'uploads to YouTube and marks uploaded' do
          expect(uploader.process!).to(eq(:uploaded))
          video.reload
          expect(video).to(be_uploaded)
          expect(video.youtube_video_id).to(eq('yt-id'))
          expect(video.youtube_uploaded_at).to(be_present)
        end
      end

      context 'and MediaConvert failed' do
        before { allow(uploader).to(receive(:media_convert_job_status).and_return('ERROR')) }

        it 'marks the video as failed' do
          expect(uploader.process!).to(eq(:failed))
          video.reload
          expect(video).to(be_failed)
          expect(video.youtube_upload_error).to(be_present)
        end
      end
    end

    context 'when already uploaded' do
      let(:video) { create(:video, :youtube_uploaded, talk:) }

      it 'is skipped' do
        expect(uploader.process!).to(eq(:skipped))
      end
    end

    context 'when there is no archive HLS' do
      let(:video) { create(:video, talk:, video_id: '') }

      it 'is skipped' do
        expect(uploader.process!).to(eq(:skipped))
      end
    end
  end
end
