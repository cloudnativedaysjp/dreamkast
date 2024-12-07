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

FactoryBot.define do
  factory :user

  factory :user_alice, class: User do
    id { 1 }
    sub { 'alice' }
    email { 'alice@example.com' }
    # conference { association :conference }
  end

  factory :user_bob, class: User do
    id { 3 }
    sub { 'bob' }
    email { 'bob@example.com' }
    # conference { association :conference }
  end
end
