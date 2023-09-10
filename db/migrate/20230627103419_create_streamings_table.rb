class CreateStreamingsTable < ActiveRecord::Migration[7.0]
  def up
    create_table :streamings, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.string :status, null: false

      t.timestamps
      t.index  [:conference_id, :track_id], unique: true
    end unless ActiveRecord::Base.connection.table_exists?(:streamings)
  end

  def down
    drop_table :streamings
  end
end
