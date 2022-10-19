class CreateRoomTable < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, foreign_key: true, type: :bigint
      t.string :name, null: false
      t.text :description
      t.integer :number_of_seats, :integer, null: false, default: 0

      t.timestamps
    end

    add_column :tracks, :room_id, :bigint, null: true, default: 0
  end
end
