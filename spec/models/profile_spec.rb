require 'rails_helper'

RSpec.describe(Profile, type: :model) do
  let(:cndt2020) { create(:cndt2020) }
  let(:profile) { create(:alice, :on_cndt2020, conference: cndt2020) }

  it 'is valid with a all params' do
    expect(profile).to(be_valid)
  end

  [:sub, :email, :first_name, :last_name, :company_name, :company_email,
   :company_postal_code, :company_address_level1, :company_address_level2, :company_address_line1,
   :company_tel, :department, :position].each do |param|
    it "is invalid without #{param}" do
      profile[param] = nil
      expect(profile).to(be_invalid)
    end
  end

  it 'is invalid if email is not a valid format' do
    profile[:email] = 'foobar'
    expect(profile).to(be_invalid)
  end

  it 'is invalid if company_email is not a valid format' do
    profile[:company_email] = 'foobar'
    expect(profile).to(be_invalid)
  end

  ['1010001'].each do |code|
    it "is valid if company_postal_code is a #{code}" do
      profile[:company_postal_code] = code
      expect(profile).to(be_valid)
    end
  end

  ['101-0001'].each do |code|
    it "is invalid if company_postal_code is a #{code}" do
      profile[:company_postal_code] = code
      expect(profile).to(be_invalid)
    end
  end

  ['09012345678', '+819012345678'].each do |tel|
    it "is valid if company_tel is a #{tel}" do
      profile[:company_tel] = tel
      expect(profile).to(be_valid)
    end
  end

  ['090-1234-5678', '+81-90-1234-5678', 'xxxxx', '09012345678X', '☀', 'amsy0810'].each do |tel|
    it "is invalid if company_tel is #{tel}" do
      profile[:company_tel] = tel
      expect(profile).to(be_invalid)
    end
  end

  context 'attend online' do
    it 'should be online' do
      expect(profile.attend_online?).to(be_truthy)
      expect(profile.attend_offline?).to(be_falsey)
    end

    it 'should return オンライン参加' do
      expect(profile.way_to_attend).to(eq('オンライン参加'))
    end
  end

  context 'attend offline' do
    before do
      profile[:participation] = Profile.participations[:offline]
    end

    it 'should be offline' do
      expect(profile.attend_online?).to(be_falsey)
      expect(profile.attend_offline?).to(be_truthy)
    end

    it 'should return 現地参加' do
      expect(profile.way_to_attend).to(eq('現地参加'))
    end
  end
end
