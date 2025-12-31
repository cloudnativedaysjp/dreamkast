class CreateSessionQuestionAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :session_question_answers, charset: 'utf8mb4', collation: 'utf8mb4_unicode_ci' do |t|
      t.bigint :session_question_id, null: false
      t.bigint :speaker_id, null: false
      t.bigint :conference_id, null: false
      t.text :body, null: false, collation: 'utf8mb4_0900_ai_ci'
      t.timestamps null: false
    end

    add_index :session_question_answers, :session_question_id
    add_index :session_question_answers, :speaker_id
    add_index :session_question_answers, :conference_id
    add_index :session_question_answers, :created_at
    add_foreign_key :session_question_answers, :session_questions
    add_foreign_key :session_question_answers, :speakers
    add_foreign_key :session_question_answers, :conferences
  end
end
