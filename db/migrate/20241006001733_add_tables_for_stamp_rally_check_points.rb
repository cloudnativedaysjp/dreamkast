class AddTablesForStampRallyCheckPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :stamp_rally_check_points, id: false do |t|
      t.string :id, limit: 26, primary_key: true
      t.references :conference, null: false, foreign_key: true
      t.references :sponsor, null: true
      t.string :type, null: false
    end
  end
end
