class AddHiddenToSessionQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :session_questions, :hidden, :boolean, default: false, null: false
    add_index :session_questions, :hidden
  end
end
