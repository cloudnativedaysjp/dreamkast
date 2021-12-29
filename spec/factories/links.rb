# == Schema Information
#
# Table name: links
#
#  id            :bigint           not null, primary key
#  description   :text(65535)
#  title         :string(255)
#  url           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_links_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
FactoryBot.define do
  factory :link do
    conference { nil }
    title { 'MyString' }
    url { 'MyString' }
    description { 'MyText' }
  end
end
