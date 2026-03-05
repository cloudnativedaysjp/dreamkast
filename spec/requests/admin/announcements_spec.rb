require 'rails_helper'

describe Admin::AnnouncementsController, type: :request do
  include ActiveJob::TestHelper

  let!(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }
  let!(:conference) { create(:cndt2020) }

  before do
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
                                                                 if arg[1] == :userinfo
                                                                   session[:userinfo]
                                                                 else
                                                                   arg[0].send(:original, arg[1])
                                                                 end
                                                               end)
  end

  after do
    clear_enqueued_jobs
  end

  describe 'POST :event/admin/announcements#create' do
    it 'creates an all_attendee announcement and enqueues prepare job when publish=true' do
      clear_enqueued_jobs

      expect do
        post(admin_announcements_path(event: 'cndt2020'),
             params: {
               announcement: {
                 publish_time: Time.zone.now,
                 body: 'test announcement for all',
                 publish: 1,
                 receiver: 'all_attendee'
               }
             })
      end.to(change(Announcement, :count).by(1))

      expect(response).to(redirect_to(admin_announcements_path(event: 'cndt2020')))
      announcement = Announcement.last
      expect(announcement.receiver).to(eq('all_attendee'))
      expect(PrepareAnnouncementDeliveriesJob).to(have_been_enqueued.with(announcement.id))
    end

    it 'creates an announcement but does not enqueue prepare job when publish=false' do
      clear_enqueued_jobs

      expect do
        post(admin_announcements_path(event: 'cndt2020'),
             params: {
               announcement: {
                 publish_time: Time.zone.now,
                 body: 'draft announcement',
                 publish: 0,
                 receiver: 'only_online'
               }
             })
      end.to(change(Announcement, :count).by(1))

      expect(response).to(redirect_to(admin_announcements_path(event: 'cndt2020')))
      expect(Announcement.last.receiver).to(eq('only_online'))
      expect(PrepareAnnouncementDeliveriesJob).not_to(have_been_enqueued)
    end

    it 'rolls back creation when enqueue fails' do
      allow(PrepareAnnouncementDeliveriesJob).to(receive(:perform_later).and_raise(StandardError, 'queue missing'))

      expect do
        post(admin_announcements_path(event: 'cndt2020'),
             params: {
               announcement: {
                 publish_time: Time.zone.now,
                 body: 'will fail',
                 publish: 1,
                 receiver: 'all_attendee'
               }
             })
      end.to(raise_error(StandardError, 'queue missing'))

      expect(Announcement.where(body: 'will fail')).to(be_empty)
    end
  end

  describe 'PATCH :event/admin/announcements/:id#update' do
    let!(:announcement) do
      Announcement.create!(
        conference:,
        publish_time: Time.zone.now,
        body: 'initial',
        publish: false,
        receiver: :all_attendee
      )
    end

    it 'does not enqueue prepare job when publish does not change' do
      clear_enqueued_jobs

      expect do
        patch(admin_announcement_path(event: 'cndt2020', id: announcement.id),
              params: {
                announcement: {
                  body: 'updated body',
                  publish: 0,
                  receiver: 'all_attendee'
                }
              })
      end.not_to(have_enqueued_job(PrepareAnnouncementDeliveriesJob))

      expect(response).to(redirect_to(admin_announcements_path(event: 'cndt2020')))
    end

    it 'enqueues prepare job when publish changes false -> true' do
      clear_enqueued_jobs

      expect do
        patch(admin_announcement_path(event: 'cndt2020', id: announcement.id),
              params: {
                announcement: {
                  body: 'publish now',
                  publish: 1,
                  receiver: 'all_attendee'
                }
              })
      end.to(have_enqueued_job(PrepareAnnouncementDeliveriesJob).with(announcement.id))

      expect(response).to(redirect_to(admin_announcements_path(event: 'cndt2020')))
    end
  end
end
