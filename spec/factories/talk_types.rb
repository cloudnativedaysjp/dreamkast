# == Schema Information
#
# Table name: talk_types
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :talk_type, class: Talk::Type do
    initialize_with { Talk::Type.find_or_initialize_by(id:) }
  end
end
