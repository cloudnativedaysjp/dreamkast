class RemoveTrackIdFromRooms < ActiveRecord::Migration[7.0]
  def change
    change_table(:rooms, bulk: true) do |t|
      t.remove_foreign_key(:tracks)
      t.remove_index(:track_id)
      t.remove(:track_id, type: :bigint, after: :conference_id)
    end
  end
end
