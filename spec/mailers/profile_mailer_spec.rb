require 'rails_helper'

RSpec.describe(ProfileMailer, type: :mailer) do
  describe '#registered' do
    describe 'one day event' do
      let!(:conference) { create(:one_day) }
      let!(:profile) { create(:alice, conference:) }

      subject(:mail) { described_class.registered(profile, conference).deliver_now }

      it { is_expected.to(have_sent_email.with_subject("#{conference.name}への登録ありがとうございます")) }
      it { is_expected.to(have_sent_email.to(profile.email)) }
      it { is_expected.to(have_sent_email.from('noreply@mail.cloudnativedays.jp')) }


      it { expect(mail.body.encoded).to(include('こんにちは、alice Alice さん。')) }
      it { expect(mail.body.encoded).to(include('この度はOne Day Conferenceにご登録いただき、誠にありがとうございます。')) }
      it { expect(mail.body.encoded).to(include('One Day Conference は3月11日(木)13:00に開催されます')) }
      it { expect(mail.body.encoded).to(include('https://event.cloudnativedays.jp/oneday')) }
      it { expect(mail.body.encoded).to(include('それでは、alice Alice さんのご参加を心からお待ちしております！')) }
    end

    describe 'two day event' do
      let!(:conference) { create(:two_day) }
      let!(:profile) { create(:alice, conference:) }

      subject(:mail) { described_class.registered(profile, conference).deliver_now }

      it { is_expected.to(have_sent_email.with_subject("#{conference.name}への登録ありがとうございます")) }
      it { is_expected.to(have_sent_email.to(profile.email)) }
      it { is_expected.to(have_sent_email.from('noreply@mail.cloudnativedays.jp')) }


      it { expect(mail.body.encoded).to(include('こんにちは、alice Alice さん。')) }
      it { expect(mail.body.encoded).to(include('この度はTwo Day Conferenceにご登録いただき、誠にありがとうございます。')) }
      it { expect(mail.body.encoded).to(include('Two Day Conference は3月11日(木)13:00から2日間にわたり開催されます。')) }
      it { expect(mail.body.encoded).to(include('https://event.cloudnativedays.jp/twoday')) }
      it { expect(mail.body.encoded).to(include('それでは、alice Alice さんのご参加を心からお待ちしております！')) }
    end
  end
end
