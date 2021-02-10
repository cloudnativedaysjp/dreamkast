class AddShowTimetableColumnToConference < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :show_timetable, :integer
  end
end
