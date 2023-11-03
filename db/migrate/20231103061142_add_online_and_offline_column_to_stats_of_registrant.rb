class AddOnlineAndOfflineColumnToStatsOfRegistrant < ActiveRecord::Migration[7.0]
  def change
    add_column :stats_of_registrants, :offline_attendees, :numeric, null: true
    add_column :stats_of_registrants, :online_attendees, :numeric, null: true
  end
end
