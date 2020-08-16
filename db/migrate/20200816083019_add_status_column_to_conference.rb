class AddStatusColumnToConference < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :status, :integer, null: false, default: 0
    add_index :conferences, :status
  end
end
