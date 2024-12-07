# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string(255)
#  sub           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_users_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

require 'rails_helper'

RSpec.describe(User, type: :model) do
  let!(:cndt2020) { create(:cndt2020) }
  let!(:user) { create(:user_alice, conference: cndt2020) }

  it 'is valid with a all params' do
    expect(user).to(be_valid)
  end

  [:sub, :email].each do |param|
    it "is invalid without #{param}" do
      user[param] = nil
      expect(user).to(be_invalid)
    end
  end

  it 'is invalid if email is not a valid format' do
    user[:email] = 'foobar'
    expect(user).to(be_invalid)
  end
end
