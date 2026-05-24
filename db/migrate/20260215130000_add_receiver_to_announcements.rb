class AddReceiverToAnnouncements < ActiveRecord::Migration[6.0]
  def change
    add_column :announcements, :receiver, :integer, null: false, default: 0
  end
end
