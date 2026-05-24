class CreateSessionQuestionVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :session_question_votes, charset: 'utf8mb4', collation: 'utf8mb4_unicode_ci' do |t|
      t.bigint :session_question_id, null: false
      t.bigint :profile_id, null: false
      t.timestamps null: false
    end

    add_index :session_question_votes, [:session_question_id, :profile_id], unique: true, name: 'index_session_question_votes_unique'
    add_index :session_question_votes, :session_question_id
    add_index :session_question_votes, :profile_id
    add_foreign_key :session_question_votes, :session_questions
    add_foreign_key :session_question_votes, :profiles
  end
end
