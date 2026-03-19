require 'rails_helper'

RSpec.describe PrepareAnnouncementDeliveriesJob, type: :job do
  include ActiveJob::TestHelper

  let!(:conference) { create(:cndt2020) }
  let!(:profile) { create(:alice, conference_id: conference.id) }
  let!(:announcement) do
    Announcement.create!(
      conference: conference,
      publish_time: Time.zone.now,
      body: 'test announcement',
      publish: true,
      receiver: :all_attendee
    )
  end

  before do
    clear_enqueued_jobs
  end

  it 'creates deliveries using delegated profile email and enqueues batch job' do
    expect do
      described_class.perform_now(announcement.id)
    end.to change(AnnouncementDelivery, :count).by(1)

    delivery = announcement.announcement_deliveries.last
    expect(delivery.email).to eq(profile.email)
    expect(delivery.status).to eq('queued')
    expect(announcement.reload.send_status).to eq('processing')
    expect(SendAnnouncementBatchJob).to have_been_enqueued.with(announcement.id)
  end
end
