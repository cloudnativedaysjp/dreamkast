require 'rails_helper'

RSpec.describe('Attendee dashboard announcements', type: :request) do
  let!(:conference) { create(:cndt2020, :opened) }

  let!(:online_recent) do
    travel_to(Conference::EARLY_BIRD_CUTOFF + 1.day) do
      create(:alice, :on_cndt2020, conference:, participation: 'オンライン参加')
    end
  end

  let!(:offline_early) do
    travel_to(Conference::EARLY_BIRD_CUTOFF - 1.day) do
      create(:bob, :on_cndt2020, conference:, participation: '現地参加')
    end
  end
  let!(:online_early_user) { create(:user, sub: 'google-oauth2|online-early', email: 'online_early@example.com') }
  let!(:online_early) do
    travel_to(Conference::EARLY_BIRD_CUTOFF - 1.day) do
      create(:alice, :on_cndt2020, conference:, participation: 'オンライン参加', user_id: online_early_user.id)
    end
  end
  let!(:offline_recent_user) { create(:user, sub: 'google-oauth2|offline-recent', email: 'offline_recent@example.com') }
  let!(:offline_recent) do
    travel_to(Conference::EARLY_BIRD_CUTOFF + 1.day) do
      create(:bob, :on_cndt2020, conference:, participation: '現地参加', user_id: offline_recent_user.id, id: nil)
    end
  end

  let!(:all_attendee) do
    Announcement.create!(conference:, receiver: :all_attendee, publish: true, publish_time: Time.zone.now, body: 'announcement all')
  end
  let!(:only_online) do
    Announcement.create!(conference:, receiver: :only_online, publish: true, publish_time: Time.zone.now, body: 'announcement online')
  end
  let!(:only_offline) do
    Announcement.create!(conference:, receiver: :only_offline, publish: true, publish_time: Time.zone.now, body: 'announcement offline')
  end
  let!(:early_bird) do
    Announcement.create!(conference:, receiver: :early_bird, publish: true, publish_time: Time.zone.now, body: 'announcement early')
  end

  def stub_session_for(sub:, email:, roles: [])
    session = {
      userinfo: {
        info: { email: },
        extra: { raw_info: { sub:, 'https://cloudnativedays.jp/roles' => roles } }
      }
    }

    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
                                                                 if arg[1] == :userinfo
                                                                   session[:userinfo]
                                                                 else
                                                                   arg[0].send(:original, arg[1])
                                                                 end
                                                               end)
  end

  describe 'GET /:event/dashboard' do
    context 'online attendee without early-bird' do
      before do
        stub_session_for(sub: 'google-oauth2|alice', email: 'alice@example.com')
      end

      it 'shows only announcements visible to the online attendee' do
        get '/cndt2020/dashboard'
        expect(response).to(be_successful)
        expect(response.body).to(include('announcement all', 'announcement online'))
        expect(response.body).not_to(include('announcement offline', 'announcement early'))
      end
    end

    context 'offline attendee with early-bird' do
      before do
        stub_session_for(sub: 'google-oauth2|bob', email: 'bob@example.com')
      end

      it 'shows only announcements visible to the offline early-bird attendee' do
        get '/cndt2020/dashboard'
        expect(response).to(be_successful)
        expect(response.body).to(include('announcement all', 'announcement offline', 'announcement early'))
        expect(response.body).not_to(include('announcement online'))
      end
    end

    context 'online attendee with early-bird' do
      before do
        stub_session_for(sub: 'google-oauth2|online-early', email: 'online_early@example.com')
      end

      it 'shows only announcements visible to the online early-bird attendee' do
        get '/cndt2020/dashboard'
        expect(response).to(be_successful)
        expect(response.body).to(include('announcement all', 'announcement online', 'announcement early'))
        expect(response.body).not_to(include('announcement offline'))
      end
    end

    context 'offline attendee without early-bird' do
      before do
        stub_session_for(sub: 'google-oauth2|offline-recent', email: 'offline_recent@example.com')
      end

      it 'shows only announcements visible to the offline non-early attendee' do
        get '/cndt2020/dashboard'
        expect(response).to(be_successful)
        expect(response.body).to(include('announcement all', 'announcement offline'))
        expect(response.body).not_to(include('announcement online', 'announcement early'))
      end
    end
  end
end
