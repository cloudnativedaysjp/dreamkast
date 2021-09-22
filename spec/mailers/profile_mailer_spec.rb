require "rails_helper"

RSpec.describe ProfileMailer, type: :mailer do
  before do

    @profile = Profile.new(
      sub: "stub",
      email: "tester@example.com",
      first_name: "Test",
      last_name: "Tester",
      industry_id: 2,
      occupation: "Solutions Architect",
      company_name: "CNDT2021",
      company_email: "cndt@test.com",
      company_address: "TOkyo",
      company_tel: "000-0000-0000",
      department: "test_department",
      position: "test_position",
      conference_id: 4
    )
  end

  describe '#registered' do
    let!(:conference) { create(:cndt2021) }

    subject(:mail) { described_class.registered(@profile, conference).deliver_now }

    it {is_expected.to have_sent_email.with_subject("#{conference.name}への登録ありがとうございます")}
    it {is_expected.to have_sent_email.to(@profile.email)}
    it {is_expected.to have_sent_email.from('noreply@mail.cloudnativedays.jp')}

  end

end
