class RemoveIntegerFromRooms < ActiveRecord::Migration[7.0]
  def change
    remove_column :rooms, :integer, :integer, default: 0, null: false, after: :number_of_seats
  end
end
