class FixColumnType < ActiveRecord::Migration[7.0]
  def change
    change_column :check_ins, :order_id, :string
    change_column :check_ins, :ticket_id, :string
  end
end
