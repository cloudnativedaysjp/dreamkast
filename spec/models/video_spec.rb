require 'rails_helper'

RSpec.describe(Video, type: :model) do
  describe '#youtube_available?' do
    context 'when uploaded and youtube_video_id present' do
      subject { build(:video, :youtube_uploaded) }

      it { is_expected.to(be_youtube_available) }
    end

    context 'when status is uploaded but youtube_video_id is blank' do
      subject { build(:video, youtube_upload_status: :uploaded, youtube_video_id: nil) }

      it { is_expected.not_to(be_youtube_available) }
    end

    context 'when youtube_video_id present but not uploaded yet' do
      subject { build(:video, youtube_upload_status: :uploading, youtube_video_id: 'dQw4w9WgXcw') }

      it { is_expected.not_to(be_youtube_available) }
    end

    context 'when default (not_uploaded)' do
      subject { build(:video) }

      it { is_expected.to(be_not_uploaded) }
      it { is_expected.not_to(be_youtube_available) }
    end
  end

  describe 'youtube_upload_status enum' do
    it 'defines the expected states' do
      expect(Video.youtube_upload_statuses).to(eq(
                                                 'not_uploaded' => 0, 'converting' => 1, 'uploading' => 2, 'uploaded' => 3, 'failed' => 4
                                               ))
    end
  end

  describe '.youtube_pending' do
    let!(:conference) { create(:cndt2020) }

    it 'includes not_uploaded and converting videos that have an archive' do
      not_uploaded = create(:video, talk: create(:talk1), video_id: 'https://example.com/a.m3u8', youtube_upload_status: :not_uploaded)
      converting = create(:video, talk: create(:talk2), video_id: 'https://example.com/b.m3u8', youtube_upload_status: :converting)
      create(:video, talk: create(:talk3), video_id: 'https://example.com/c.m3u8', youtube_upload_status: :uploaded)
      create(:video, talk: create(:talk_cm), video_id: '', youtube_upload_status: :not_uploaded)

      expect(Video.youtube_pending).to(contain_exactly(not_uploaded, converting))
    end
  end
end
