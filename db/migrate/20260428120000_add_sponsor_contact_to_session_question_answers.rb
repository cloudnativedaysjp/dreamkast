class AddSponsorContactToSessionQuestionAnswers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :session_question_answers, :speaker_id, true

    add_column :session_question_answers, :sponsor_contact_id, :bigint
    add_index :session_question_answers, :sponsor_contact_id
    add_foreign_key :session_question_answers, :sponsor_contacts
  end
end
