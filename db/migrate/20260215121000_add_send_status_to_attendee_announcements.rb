class AddSendStatusToAttendeeAnnouncements < ActiveRecord::Migration[6.0]
  def change
    change_table :attendee_announcements, bulk: true do |t|
      t.string :send_status, null: false, default: 'pending'
      t.integer :sent_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0
      t.integer :bounced_count, null: false, default: 0
      t.integer :suppressed_count, null: false, default: 0
      t.datetime :send_started_at
      t.datetime :send_completed_at
    end
  end
end
