class AddTablesForStampRally < ActiveRecord::Migration[7.0]
  def change
    create_table :booth_stamp_rally_defs do |t|
      t.references :conference, null: false, foreign_key: true
      t.references :sponsor, null: false, foreign_key: true
    end

    create_table :check_in_booth_stamp_rallies do |t|
      t.references :booth_stamp_rally_defs, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.datetime :check_in_timestamp, null: false
    end
  end
end
