class SessionQuestionVote < ApplicationRecord
  belongs_to :session_question
  belongs_to :profile

  validates :session_question_id, uniqueness: { scope: :profile_id }

  # 投票作成後に質問の投票数を更新
  after_create :update_question_votes_count
  after_destroy :update_question_votes_count

  private

  def update_question_votes_count
    # エラーが発生しても投票の作成/削除は成功させる
    begin
      session_question.update_votes_count!
    rescue StandardError => e
      Rails.logger.error "Error updating votes_count: #{e.class} - #{e.message}"
      # エラーをログに記録するが、投票の処理は続行
    end
  end
end
