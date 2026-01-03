class SessionQuestionVote < ApplicationRecord
  belongs_to :session_question, counter_cache: :votes_count
  belongs_to :profile

  validates :session_question_id, uniqueness: { scope: :profile_id }
end
