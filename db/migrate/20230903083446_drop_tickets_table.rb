class DropTicketsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :cancel_orders
    drop_table :orders_tickets
    drop_table :tickets
    drop_table :orders
  end
end
