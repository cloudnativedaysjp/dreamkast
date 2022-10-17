class AddSeatsColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :talks, :number_of_seats, :integer, null: false, default: 0
    add_column :talks, :acquired_seats, :integer, null: false, default: 0
  end
end
