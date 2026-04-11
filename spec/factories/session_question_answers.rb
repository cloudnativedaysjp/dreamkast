FactoryBot.define do
  factory :session_question_answer do
    body { 'これはテスト回答です' }
    association :session_question
    association :speaker
    association :conference
  end
end
