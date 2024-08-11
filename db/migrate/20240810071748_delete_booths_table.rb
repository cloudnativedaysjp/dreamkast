class DeleteBoothsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :booths
  end
end
