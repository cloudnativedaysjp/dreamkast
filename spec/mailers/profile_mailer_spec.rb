require 'rails_helper'

RSpec.describe(ProfileMailer, type: :mailer) do
  before do
    @profile = Profile.new(
      sub: 'stub',
      email: 'tester@example.com',
      first_name: 'Test',
      last_name: 'Tester',
      industry_id: 2,
      occupation: 'Solutions Architect',
      company_name: 'CNDT2021',
      company_email: 'cndt@test.com',
      company_address: 'TOkyo',
      company_tel: '000-0000-0000',
      department: 'test_department',
      position: 'test_position',
      conference_id: 4
    )
  end

  describe '#registered' do
    describe 'one day event' do
      let!(:conference) { create(:one_day) }

      subject(:mail) { described_class.registered(@profile, conference).deliver_now }

      it { is_expected.to(have_sent_email.with_subject("#{conference.name}への登録ありがとうございます")) }
      it { is_expected.to(have_sent_email.to(@profile.email)) }
      it { is_expected.to(have_sent_email.from('noreply@mail.cloudnativedays.jp')) }


      it { expect(mail.body.encoded).to(include('こんにちは、Tester Test さん。')) }
      it { expect(mail.body.encoded).to(include('この度はOne Day Conferenceにご登録いただき、誠にありがとうございます。')) }
      it { expect(mail.body.encoded).to(include('One Day Conference は3月11日(木)13:00に開催されます')) }
      it { expect(mail.body.encoded).to(include('https://event.cloudnativedays.jp/oneday')) }
      it { expect(mail.body.encoded).to(include('それでは、Tester Test さんのご参加を心からお待ちしております！')) }
    end

    describe 'two day event' do
      let!(:conference) { create(:two_day) }

      subject(:mail) { described_class.registered(@profile, conference).deliver_now }

      it { is_expected.to(have_sent_email.with_subject("#{conference.name}への登録ありがとうございます")) }
      it { is_expected.to(have_sent_email.to(@profile.email)) }
      it { is_expected.to(have_sent_email.from('noreply@mail.cloudnativedays.jp')) }


      it { expect(mail.body.encoded).to(include('こんにちは、Tester Test さん。')) }
      it { expect(mail.body.encoded).to(include('この度はTwo Day Conferenceにご登録いただき、誠にありがとうございます。')) }
      it { expect(mail.body.encoded).to(include('Two Day Conference は3月11日(木)13:00から2日間にわたり開催されます。')) }
      it { expect(mail.body.encoded).to(include('https://event.cloudnativedays.jp/twoday')) }
      it { expect(mail.body.encoded).to(include('それでは、Tester Test さんのご参加を心からお待ちしております！')) }
    end
  end
end
