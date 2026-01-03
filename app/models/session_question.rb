class SessionQuestion < ApplicationRecord
  belongs_to :talk
  belongs_to :conference
  belongs_to :profile
  has_many :session_question_answers, dependent: :destroy
  has_many :session_question_votes, dependent: :destroy

  validates :body, presence: true

  # 投票数はcounter_cacheで自動管理される
  # データ整合性チェック用に、手動でカウントを再計算するメソッドを提供
  def update_votes_count!
    # counter_cacheを使用しているため、通常はこのメソッドは不要
    # データ不整合が発生した場合の修復用として残す
    self.class.reset_counters(id, :session_question_votes)
    reload
  end

  # スコープ
  scope :for_talk, ->(talk_id) { where(talk_id:) }
  scope :order_by_votes, -> { order(votes_count: :desc, created_at: :desc) }
  scope :order_by_time, -> { order(created_at: :desc) }
  scope :visible, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }
end
