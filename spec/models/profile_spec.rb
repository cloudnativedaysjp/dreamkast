# == Schema Information
#
# Table name: profiles
#
#  id                            :bigint           not null, primary key
#  calendar_unique_code          :string(255)
#  company_address               :string(255)
#  company_address_level1        :string(255)
#  company_address_level2        :string(255)
#  company_address_line1         :string(255)
#  company_address_line2         :string(255)
#  company_email                 :string(255)
#  company_fax                   :string(255)
#  company_name                  :string(255)
#  company_postal_code           :string(255)
#  company_tel                   :string(255)
#  department                    :string(255)
#  email                         :string(255)
#  first_name                    :string(255)
#  first_name_kana               :string(255)
#  last_name                     :string(255)
#  last_name_kana                :string(255)
#  occupation                    :string(255)
#  participation                 :string(255)
#  position                      :string(255)
#  sub                           :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  annual_sales_id               :integer          default(11)
#  company_address_prefecture_id :string(255)
#  company_name_prefix_id        :string(255)
#  company_name_suffix_id        :string(255)
#  conference_id                 :integer
#  industry_id                   :integer
#  number_of_employee_id         :integer          default(12)
#  occupation_id                 :integer          default(34)
#

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
