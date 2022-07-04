# == Schema Information
#
# Table name: profiles
#
#  id                            :integer          not null, primary key
#  sub                           :string(255)
#  email                         :string(255)
#  last_name                     :string(255)
#  first_name                    :string(255)
#  industry_id                   :integer
#  occupation                    :string(255)
#  company_name                  :string(255)
#  company_email                 :string(255)
#  company_address               :string(255)
#  company_tel                   :string(255)
#  department                    :string(255)
#  position                      :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  conference_id                 :integer
#  company_address_prefecture_id :string(255)
#  first_name_kana               :string(255)
#  last_name_kana                :string(255)
#  company_name_prefix_id        :string(255)
#  company_name_suffix_id        :string(255)
#  company_postal_code           :string(255)
#  company_address_level1        :string(255)
#  company_address_level2        :string(255)
#  company_address_line1         :string(255)
#  company_address_line2         :string(255)
#  number_of_employee_id         :integer          default("12")
#  annual_sales_id               :integer          default("11")
#  company_fax                   :string(255)
#

require 'rails_helper'

RSpec.describe(Profile, type: :model) do
  before do
    create(:cndt2020)

    @profile = Profile.new(
      sub: 'stub',
      email: 'tester@example.com',
      first_name: 'Test',
      last_name: 'Tester',
      industry_id: 2,
      occupation: 'Solutions Architect',
      company_name: 'CNDT',
      company_email: 'cndt@example.com',
      company_postal_code: '1000001',
      company_address_level1: 'address level 1',
      company_address_level2: 'address level 2',
      company_address_line1: 'address line 1',
      company_address_line2: 'address line 2',
      company_tel: '00000000000',
      department: 'aaaaaa',
      position: 'bbbbbb',
      conference_id: 1
    )
  end

  it 'is valid with a all params' do
    expect(@profile).to(be_valid)
  end

  [:sub, :email, :first_name, :last_name, :company_name, :company_email,
   :company_postal_code, :company_address_level1, :company_address_level2, :company_address_line1, :company_address_line2,
   :company_tel].each do |param|
    it "is invalid without #{param}" do
      @profile[param] = nil
      expect(@profile).to(be_invalid)
    end
  end

  it 'is invalid if email is not a valid format' do
    @profile[:email] = 'foobar'
    expect(@profile).to(be_invalid)
  end

  it 'is invalid if company_email is not a valid format' do
    @profile[:email] = 'foobar'
    expect(@profile).to(be_invalid)
  end

  ['1010001'].each do |code|
    it "is valid if company_postal_code is a #{code}" do
      @profile[:company_postal_code] = code
      expect(@profile).to(be_valid)
    end
  end

  ['101-0001'].each do |code|
    it "is invalid if company_postal_code is a #{code}" do
      @profile[:company_postal_code] = code
      expect(@profile).to(be_invalid)
    end
  end

  ['09012345678', '+819012345678'].each do |tel|
    it "is valid if company_tel is a #{tel}" do
      @profile[:company_tel] = tel
      expect(@profile).to(be_valid)
    end
  end

  ['090-1234-5678', '+81-90-1234-5678', 'xxxxx', '09012345678X', '☀', 'amsy0810'].each do |tel|
    it "is invalid if company_tel is #{tel}" do
      @profile[:company_tel] = tel
      expect(@profile).to(be_invalid)
    end
  end
end
