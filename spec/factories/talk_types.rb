FactoryBot.define do
  factory :talk_type, class: Talk::Type do
    initialize_with { Talk::Type.find_or_initialize_by(id:) }
  end
end
