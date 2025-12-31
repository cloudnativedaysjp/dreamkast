class CreateSessionQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :session_questions, charset: 'utf8mb4', collation: 'utf8mb4_unicode_ci' do |t|
      t.bigint :talk_id, null: false
      t.bigint :conference_id, null: false
      t.bigint :profile_id, null: false
      t.text :body, null: false, collation: 'utf8mb4_0900_ai_ci'
      t.integer :votes_count, default: 0, null: false
      t.timestamps null: false
    end

    add_index :session_questions, :talk_id
    add_index :session_questions, :conference_id
    add_index :session_questions, :profile_id
    add_index :session_questions, :created_at
    add_index :session_questions, :votes_count
    add_foreign_key :session_questions, :talks
    add_foreign_key :session_questions, :conferences
    add_foreign_key :session_questions, :profiles
  end
end
