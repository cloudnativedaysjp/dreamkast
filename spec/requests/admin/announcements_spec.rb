require 'rails_helper'

describe Admin::AnnouncementsController, type: :request do
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

  describe 'POST :event/admin/announcements#create' do
    let!(:profile) { create(:alice, :on_cndt2020, conference:) }

    it 'creates a person announcement with target profiles' do
      post admin_announcements_path(event: 'cndt2020'),
           params: {
             announcement: {
               publish_time: Time.zone.now,
               body: 'test announcement for alice',
               publish: 1,
               receiver: 'person',
               profile_ids: [profile.id]
             }
           }

      expect(response).to(redirect_to(admin_announcements_path(event: 'cndt2020')))
      announcement = Announcement.last
      expect(announcement.receiver).to(eq('person'))
      expect(announcement.profiles).to(contain_exactly(profile))
    end

    it 'ignores profile_ids when receiver is all_attendee' do
      post admin_announcements_path(event: 'cndt2020'),
           params: {
             announcement: {
               publish_time: Time.zone.now,
               body: 'test announcement for all',
               publish: 1,
               receiver: 'all_attendee',
               profile_ids: [profile.id]
             }
           }

      expect(response).to(redirect_to(admin_announcements_path(event: 'cndt2020')))
      announcement = Announcement.last
      expect(announcement.receiver).to(eq('all_attendee'))
      expect(announcement.profiles).to(be_empty)
    end
  end
end
