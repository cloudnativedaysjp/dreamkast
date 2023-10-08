class AddErrorCauseColumnToStreamings < ActiveRecord::Migration[7.0]
  def change
    add_column :streamings, :error_cause, :text, null: true
  end
end
