class AddPositionToStampRallyCheckPoints < ActiveRecord::Migration[7.0]
  def change
    add_column :stamp_rally_check_points, :position, :integer
  end
end
