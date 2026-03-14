class AddSendStatusToAnnouncements < ActiveRecord::Migration[8.0]
  def change
    add_column(:announcements, :send_status, :string, default: 'pending')
    add_column(:announcements, :sent_count, :integer, default: 0, null: false)
    add_column(:announcements, :failed_count, :integer, default: 0, null: false)
  end
end
