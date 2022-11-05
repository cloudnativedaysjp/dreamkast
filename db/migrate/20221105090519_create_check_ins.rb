class CreateCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :check_ins do |t|
      t.integer :profile_id
      t.integer :order_id
      t.integer :ticket_id

      t.timestamps
    end
    add_index :check_ins, :profile_id
    add_index :check_ins, :order_id
    add_index :check_ins, :ticket_id
  end
end
