class AddNewCheckInsTables < ActiveRecord::Migration[7.0]
  def change
    create_table :check_in_conferences do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :profile, null: false, foreign_key: true
      t.datetime :check_in_timestamp, null: false

      t.timestamps
    end

    create_table :check_in_talks do |t|
      t.belongs_to :talk, null: false, foreign_key: true
      t.belongs_to :profile, null: false, foreign_key: true
      t.datetime :check_in_timestamp, null: false

      t.timestamps
    end
  end
end
