class RemoveTicketRelationFromCheckin < ActiveRecord::Migration[7.0]
  def change
    remove_column :check_ins, :ticket_id, :integer
    remove_column :check_ins, :order_id, :integer
  end
end
