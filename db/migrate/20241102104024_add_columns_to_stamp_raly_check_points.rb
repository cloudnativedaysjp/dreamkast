class AddColumnsToStampRalyCheckPoints < ActiveRecord::Migration[7.0]
  def change
    add_column :stamp_rally_check_points, :name, :string, null: false
    add_column :stamp_rally_check_points, :description, :string, null: false
  end
end
