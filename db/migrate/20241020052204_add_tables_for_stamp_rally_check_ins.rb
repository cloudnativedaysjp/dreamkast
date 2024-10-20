class AddTablesForStampRallyCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :stamp_rally_check_ins, id: false do |t|
      t.string :id, limit: 26, primary_key: true
      t.references :stamp_rally_check_point, type: :string, limit: 26, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.datetime :check_in_timestamp, null: false
    end
  end
end
