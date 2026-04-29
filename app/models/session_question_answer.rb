class SessionQuestionAnswer < ApplicationRecord
  belongs_to :session_question
  belongs_to :speaker, optional: true
  belongs_to :sponsor_contact, optional: true
  belongs_to :conference

  validates :body, presence: true
  validate :exactly_one_answerer

  # スコープ
  scope :for_question, ->(question_id) { where(session_question_id: question_id) }
  scope :order_by_time, -> { order(created_at: :asc) }

  def answerer_type
    return 'speaker' if speaker_id.present?
    return 'sponsor' if sponsor_contact_id.present?
    nil
  end

  def answerer_display_name
    if speaker_id.present?
      speaker&.name
    elsif sponsor_contact_id.present?
      speaker_name_for_sponsor_contact || 'スポンサー担当者'
    end
  end

  private

  def speaker_name_for_sponsor_contact
    user_id = sponsor_contact&.user_id
    talk = session_question&.talk
    return nil unless user_id && talk

    talk.speakers.find_by(user_id:)&.name
  end

  def exactly_one_answerer
    if speaker_id.blank? && sponsor_contact_id.blank?
      errors.add(:base, 'speaker または sponsor_contact のいずれかが必要です')
    elsif speaker_id.present? && sponsor_contact_id.present?
      errors.add(:base, 'speaker と sponsor_contact は同時に指定できません')
    end
  end
end
