FactoryBot.define do
  factory :session_question do
    body { 'これはテスト質問です' }
    votes_count { 0 }
    hidden { false }
    association :talk
    association :conference
    association :profile

    trait :hidden do
      hidden { true }
    end

    trait :with_votes do
      after(:create) do |question|
        create_list(:session_question_vote, 3, session_question: question)
        question.update_votes_count!
      end
    end
  end
end
