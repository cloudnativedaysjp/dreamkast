FactoryBot.define do
  factory :session_question_vote do
    association :session_question
    association :profile
  end
end
