require 'rails_helper'

RSpec.describe(SendAnnouncementBatchJob, type: :job) do
  include ActiveJob::TestHelper

  let!(:conference) { create(:one_day) }
  let!(:profile) { create(:alice, conference:) }
  let!(:announcement) do
    Announcement.create!(
      conference:,
      receiver: :all_attendee,
      publish: false,
      publish_time: Time.zone.now,
      body: 'テストお知らせ',
      send_status: :processing
    )
  end
  let!(:delivery) do
    AnnouncementDelivery.create!(
      announcement:,
      profile:,
      email: profile.email,
      status: :queued
    )
  end

  describe '#perform' do
    context '送信成功の場合' do
      before do
        fake_message = double('message', message_id: 'ses-message-id-001')
        allow(AnnouncementMailer).to(receive_message_chain(:notify, :deliver_now).and_return(fake_message))
      end

      it 'delivery の status を sent に更新する' do
        described_class.perform_now(announcement.id)
        expect(delivery.reload.status).to(eq('sent'))
      end

      it 'delivery の provider_message_id を更新する' do
        described_class.perform_now(announcement.id)
        expect(delivery.reload.provider_message_id).to(eq('ses-message-id-001'))
      end

      it 'announcement の sent_count を更新する' do
        described_class.perform_now(announcement.id)
        expect(announcement.reload.sent_count).to(eq(1))
      end

      it 'queued がなくなったら send_status を completed に更新する' do
        described_class.perform_now(announcement.id)
        expect(announcement.reload.send_status).to(eq('completed'))
      end
    end

    context '送信失敗の場合' do
      before do
        allow(AnnouncementMailer).to(receive_message_chain(:notify, :deliver_now).and_raise(StandardError, '送信エラー'))
      end

      it 'delivery の status を failed に更新する' do
        described_class.perform_now(announcement.id)
        expect(delivery.reload.status).to(eq('failed'))
      end

      it 'delivery の last_error にエラーメッセージを保存する' do
        described_class.perform_now(announcement.id)
        expect(delivery.reload.last_error).to(eq('送信エラー'))
      end

      it 'announcement の failed_count を更新する' do
        described_class.perform_now(announcement.id)
        expect(announcement.reload.failed_count).to(eq(1))
      end

      it 'queued がなくなったら send_status を completed に更新する' do
        described_class.perform_now(announcement.id)
        expect(announcement.reload.send_status).to(eq('completed'))
      end
    end

    context 'まだ queued な delivery が残っている場合' do
      let!(:delivery2) do
        AnnouncementDelivery.create!(
          announcement:,
          profile:,
          email: profile.email,
          status: :queued
        )
      end

      before do
        stub_const('SendAnnouncementBatchJob::BATCH_SIZE', 1)
        fake_message = double('message', message_id: 'ses-message-id-001')
        allow(AnnouncementMailer).to(receive_message_chain(:notify, :deliver_now).and_return(fake_message))
      end

      it '次の SendAnnouncementBatchJob をキューに積む' do
        expect do
          described_class.perform_now(announcement.id)
        end.to(have_enqueued_job(described_class).with(announcement.id))
      end
    end
  end
end
