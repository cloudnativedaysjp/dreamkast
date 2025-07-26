# == Schema Information
#
# Table name: links
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  title         :string(255)
#  url           :string(255)
#  description   :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_links_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :link do
    conference { nil }
    title { 'MyString' }
    url { 'MyString' }
    description { 'MyText' }
  end
end
