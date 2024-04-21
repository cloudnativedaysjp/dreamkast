# == Schema Information
#
# Table name: admin_profiles
#
#  id                :bigint           not null, primary key
#  avatar_data       :text(65535)
#  email             :string(255)
#  name              :string(255)
#  show_on_team_page :boolean
#  sub               :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  conference_id     :bigint           not null
#  github_id         :string(255)
#  twitter_id        :string(255)
#
# Indexes
#
#  index_admin_profiles_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
FactoryBot.define do
  factory :admin_profile
end
