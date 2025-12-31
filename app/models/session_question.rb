class SessionQuestion < ApplicationRecord
  belongs_to :talk
  belongs_to :conference
  belongs_to :profile
  has_many :session_question_answers, dependent: :destroy
  has_many :session_question_votes, dependent: :destroy

  validates :body, presence: true, length: { maximum: 512 }

  # 投票数の更新（counter_cache的な役割）
  def update_votes_count!
    new_count = session_question_votes.count
    update_column(:votes_count, new_count)
  rescue StandardError => e
    Rails.logger.error "Error in update_votes_count!: #{e.class} - #{e.message}"
    raise
  end

  # スコープ
  scope :for_talk, ->(talk_id) { where(talk_id: talk_id) }
  scope :order_by_votes, -> { order(votes_count: :desc, created_at: :desc) }
  scope :order_by_time, -> { order(created_at: :desc) }
end
