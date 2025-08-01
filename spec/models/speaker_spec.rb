require 'rails_helper'

RSpec.describe(Speaker, type: :model) do
  before { create(:cndt2020) }

  describe '#has_accepted_proposal?' do
    subject { speaker.has_accepted_proposal? }

    context 'when speaker has accepted talk' do
      let!(:speaker) { create(:speaker_alice, :with_talk1_accepted) }
      it { expect(subject).to(be_truthy) }
    end

    context 'when speaker has accepted and rejected talks' do
      let!(:speaker) { create(:speaker_alice, :with_talk1_accepted) }
      before { speaker.talks << create(:talk_rejekt) }
      it { expect(subject).to(be_truthy) }
    end

    context 'when speaker has only rejected talk' do
      let!(:speaker) { create(:speaker_alice, :with_talk1_rejected) }
      it { expect(subject).to(be_falsey) }
    end
  end

  describe '#avatar_full_url' do
    subject { speaker.avatar_full_url }
    before { allow(speaker).to(receive(:avatar_url).and_return('/test_image.jpg')) }
    let!(:speaker) { create(:speaker_alice) }

    context 'when speaker has avatar_data' do
      it { is_expected.to(eq("https://#{ENV.fetch('S3_BUCKET', '')}.s3.#{ENV.fetch('S3_REGION', '')}.amazonaws.com/test_image.jpg")) }
    end
  end
end
