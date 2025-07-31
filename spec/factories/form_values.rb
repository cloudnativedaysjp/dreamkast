FactoryBot.define do
  factory :form_value do
    association :profile
    association :form_item
    value { 'テストの回答内容' }
  end
end
