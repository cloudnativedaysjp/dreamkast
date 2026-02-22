require 'rails_helper'

RSpec.describe(Announcement, type: :model) do
  describe '#target_profiles' do
    let!(:conference) { create(:one_day) }
    let!(:online_profile) { create(:alice, conference:, participation: 'オンライン参加') }
    let!(:offline_profile) { create(:bob, conference:, participation: '現地参加') }

    context 'receiver が all_attendee の場合' do
      let(:announcement) do
        Announcement.create!(conference:, receiver: :all_attendee, publish: false, publish_time: Time.zone.now, body: 'test')
      end

      it '全プロフィールを返す' do
        expect(announcement.target_profiles).to(include(online_profile, offline_profile))
      end
    end

    context 'receiver が only_online の場合' do
      let(:announcement) do
        Announcement.create!(conference:, receiver: :only_online, publish: false, publish_time: Time.zone.now, body: 'test')
      end

      it 'オンライン参加プロフィールのみ返す' do
        expect(announcement.target_profiles).to(include(online_profile))
        expect(announcement.target_profiles).not_to(include(offline_profile))
      end
    end

    context 'receiver が only_offline の場合' do
      let(:announcement) do
        Announcement.create!(conference:, receiver: :only_offline, publish: false, publish_time: Time.zone.now, body: 'test')
      end

      it '現地参加プロフィールのみ返す' do
        expect(announcement.target_profiles).to(include(offline_profile))
        expect(announcement.target_profiles).not_to(include(online_profile))
      end
    end

    context 'receiver が early_bird の場合' do
      let(:announcement) do
        Announcement.create!(conference:, receiver: :early_bird, publish: false, publish_time: Time.zone.now, body: 'test')
      end

      it '先行申込プロフィールを返す' do
        online_profile.update_column(:created_at, Conference::EARLY_BIRD_CUTOFF - 1.day)
        expect(announcement.target_profiles).to(include(online_profile))
      end

      it 'EARLY_BIRD_CUTOFF 以降のプロフィールを含まない' do
        online_profile.update_column(:created_at, Conference::EARLY_BIRD_CUTOFF + 1.day)
        expect(announcement.target_profiles).not_to(include(online_profile))
      end
    end
  end

  describe 'after_save :schedule_delivery' do
    let!(:conference) { create(:one_day) }

    it 'publish が true になった際に PrepareAnnouncementDeliveriesJob をキューに積む' do
      announcement = Announcement.create!(conference:, receiver: :all_attendee, publish: false, publish_time: Time.zone.now, body: 'test')
      expect do
        announcement.update!(publish: true)
      end.to(have_enqueued_job(PrepareAnnouncementDeliveriesJob).with(announcement.id))
    end

    it 'publish が変わらない場合はジョブをキューに積まない' do
      announcement = Announcement.create!(conference:, receiver: :all_attendee, publish: false, publish_time: Time.zone.now, body: 'test')
      expect do
        announcement.update!(body: '更新テスト')
      end.not_to(have_enqueued_job(PrepareAnnouncementDeliveriesJob))
    end
  end
end
