# == Schema Information
#
# Table name: admin_profiles
#
#  id                :integer          not null, primary key
#  conference_id     :integer          not null
#  sub               :string(255)
#  email             :string(255)
#  name              :string(255)
#  twitter_id        :string(255)
#  github_id         :string(255)
#  avatar_data       :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  show_on_team_page :boolean
#
# Indexes
#
#  index_admin_profiles_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :admin_profile
end
