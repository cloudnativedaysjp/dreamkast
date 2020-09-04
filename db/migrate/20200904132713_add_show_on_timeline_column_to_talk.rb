class AddShowOnTimelineColumnToTalk < ActiveRecord::Migration[6.0]
  def change
    add_column :talks, :show_on_timetable, :boolean
  end
end
