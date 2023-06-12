class AddDefaultValuesToConference < ActiveRecord::Migration[7.0]
  def change
    change_column :conferences, :conference_status, :string, default: Conference::STATUS_REGISTERED
    change_column :conferences, :speaker_entry, :integer, default: 0
    change_column :conferences, :attendee_entry, :integer, default: 0
    change_column :conferences, :show_timetable, :integer, default: 0
  end
end
