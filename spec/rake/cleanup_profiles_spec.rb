require 'rails_helper'
require 'rake'

describe 'cleanup_profiles' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('cleanup_profiles', ["#{Rails.root}/lib/tasks"])
    Rake::Task.define_task(:environment)
    ENV['EVENT_ABBR'] = 'cndt2020'
  end

  before(:each) do
    @rake[task].reenable
  end

  let(:task) { 'util:cleanup_profiles' }

  describe 'archived conference' do
    let!(:cndt2020) { create(:cndt2020, :archived) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:talk) { create(:talk1) }
    let!(:registered_talk) { create(:registered_talk, profile: alice, talk:) }
    let!(:form_item) { create(:form_item1) }
    let!(:form_value) { create(:form_value, profile: alice, form_item:) }
    let!(:sponsor) { create(:sponsor, conference: cndt2020) }
    let!(:stamp_rally_check_point) { create(:stamp_rally_check_point_booth, conference: cndt2020, sponsor:) }
    let!(:stamp_rally_check_in) { create(:stamp_rally_check_in, profile: alice, stamp_rally_check_point:, check_in_timestamp: Time.current) }
    let!(:chat_message) { create(:message_from_alice, conference_id: cndt2020.id, profile: alice, room_id: talk.id) }
    let(:task) { 'util:cleanup_profiles' }

    it 'delete profiles related of conference' do
      @rake[task].invoke
      expect(Profile.where(conference_id: cndt2020.id).size).to(eq(0))
    end

    it 'delete registered talks related of profile' do
      @rake[task].invoke
      expect(RegisteredTalk.where(profile_id: alice.id).size).to(eq(0))
    end

    it 'doesn\'t delete chat messages related of profile' do
      @rake[task].invoke
      expect(ChatMessage.where(conference_id: cndt2020.id).size).to(eq(1))
      expect(ChatMessage.find_by(conference_id: cndt2020.id).profile).to(eq(nil))
    end

    it 'deletes stamp rally check ins and form values related of profile' do
      @rake[task].invoke
      expect(StampRallyCheckIn.where(profile_id: alice.id).size).to(eq(0))
      expect(FormValue.where(profile_id: alice.id).size).to(eq(0))
    end
  end

  describe 'registered conference' do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    it 'doesn\'t work' do
      expect { @rake[task].invoke }.to(raise_error('cndt2020 is not archived or migrated yet'))
    end
  end

  describe 'opened conference' do
    let!(:cndt2020) { create(:cndt2020, :opened) }

    it 'doesn\'t work' do
      expect { @rake[task].invoke }.to(raise_error('cndt2020 is not archived or migrated yet'))
    end
  end

  describe 'closed conference' do
    let!(:cndt2020) { create(:cndt2020, :closed) }

    it 'doesn\'t work' do
      expect { @rake[task].invoke }.to(raise_error('cndt2020 is not archived or migrated yet'))
    end
  end
end
