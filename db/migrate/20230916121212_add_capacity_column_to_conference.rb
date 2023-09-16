class AddCapacityColumnToConference < ActiveRecord::Migration[7.0]
  def change
    add_column :conferences, :capacity, :integer
  end
end
