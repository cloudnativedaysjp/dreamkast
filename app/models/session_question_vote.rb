class SessionQuestionVote < ApplicationRecord
  belongs_to :session_question
  belongs_to :profile

  validates :session_question_id, uniqueness: { scope: :profile_id }

  # 投票作成/削除後に質問の投票数を更新（トランザクションコミット後）
  after_commit :update_question_votes_count, on: [:create, :destroy]

  private

  def update_question_votes_count
    # トランザクションがコミットされた後に投票数を更新
    # エラーが発生した場合はログに記録し、再試行する
    retries = 0
    max_retries = 3
    
    begin
      session_question.update_votes_count!
    rescue StandardError => e
      retries += 1
      Rails.logger.error "Error updating votes_count (attempt #{retries}/#{max_retries}): #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      if retries < max_retries
        # 短い待機時間後に再試行
        sleep(0.1 * retries)
        retry
      else
        # 最大再試行回数に達した場合は、エラーを通知（監視システムなど）
        Rails.logger.error "Failed to update votes_count after #{max_retries} attempts for session_question_id: #{session_question_id}"
        # 必要に応じて、エラー通知サービス（Sentryなど）に送信
        # Sentry.capture_exception(e) if defined?(Sentry)
      end
    end
  end
end
