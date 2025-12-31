class SessionQuestionAnswer < ApplicationRecord
  belongs_to :session_question
  belongs_to :speaker
  belongs_to :conference

  validates :body, presence: true, length: { maximum: 512 }

  # スコープ
  scope :for_question, ->(question_id) { where(session_question_id: question_id) }
  scope :order_by_time, -> { order(created_at: :asc) }
end
