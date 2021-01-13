class AddSpeakerEntryAndAttendeeEntryColumnsToConference < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :speaker_entry, :integer
    add_column :conferences, :attendee_entry, :integer
  end
end
