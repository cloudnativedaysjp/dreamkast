require 'rails_helper'

RSpec.describe(PrepareAnnouncementDeliveriesJob, type: :job) do
  include ActiveJob::TestHelper

  let!(:conference) { create(:one_day) }
  let!(:profile) { create(:alice, conference:) }
  let!(:announcement) do
    Announcement.create!(
      conference:,
      receiver: :all_attendee,
      publish: false,
      publish_time: Time.zone.now,
      body: 'テスト'
    )
  end

  describe '#perform' do
    it 'announcement_deliveries を対象プロフィール分作成する' do
      expect do
        described_class.perform_now(announcement.id)
      end.to(change(AnnouncementDelivery, :count).by(1))
    end

    it 'delivery のメールアドレスがプロフィールのメールと一致する' do
      described_class.perform_now(announcement.id)
      delivery = AnnouncementDelivery.last
      expect(delivery.email).to(eq(profile.email))
    end

    it 'delivery のステータスが queued になる' do
      described_class.perform_now(announcement.id)
      delivery = AnnouncementDelivery.last
      expect(delivery.status).to(eq('queued'))
    end

    it 'announcement の send_status を processing に更新する' do
      described_class.perform_now(announcement.id)
      expect(announcement.reload.send_status).to(eq('processing'))
    end

    it 'SendAnnouncementBatchJob をキューに積む' do
      expect do
        described_class.perform_now(announcement.id)
      end.to(have_enqueued_job(SendAnnouncementBatchJob).with(announcement.id))
    end
  end
end
