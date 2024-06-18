# == Schema Information
#
# Table name: announcements
#
#  id            :bigint           not null, primary key
#  body          :text(16777215)
#  publish       :boolean
#  publish_time  :datetime
#  conference_id :bigint           not null
#
# Indexes
#
#  index_announcements_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
FactoryBot.define do
  factory :announcement
end
