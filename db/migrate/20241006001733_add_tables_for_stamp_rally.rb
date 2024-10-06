class AddTablesForStampRally < ActiveRecord::Migration[7.0]
  def change
    create_table :stamp_rally_defs do |t|
      t.references :conference, null: false, foreign_key: true
      t.references :sponsor, null: true
      t.string :type, null: false
    end

    create_table :check_in_stamp_rallies do |t|
      t.references :stamp_rally_def, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.datetime :check_in_timestamp, null: false
    end
  end
end
