require 'rails_helper'

RSpec.describe(AnnouncementMailer, type: :mailer) do
  describe '#notify' do
    let!(:conference) { create(:one_day) }
    let!(:profile) { create(:alice, conference:) }
    let!(:announcement) do
      Announcement.create!(
        conference:,
        receiver: :all_attendee,
        publish: false,
        publish_time: Time.zone.now,
        body: 'テストお知らせ本文です。'
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

    subject(:mail) { described_class.notify(announcement, delivery).deliver_now }

    it { is_expected.to(have_sent_email.with_subject("#{conference.name}からのお知らせ")) }
    it { is_expected.to(have_sent_email.to(profile.email)) }
    it { is_expected.to(have_sent_email.from('noreply@mail.cloudnativedays.jp')) }
    it { expect(mail.body.encoded).to(include('テストお知らせ本文です。')) }
  end
end
