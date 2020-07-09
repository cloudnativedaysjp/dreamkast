class AddColumnToConference < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :abbr, :string
  end
end
