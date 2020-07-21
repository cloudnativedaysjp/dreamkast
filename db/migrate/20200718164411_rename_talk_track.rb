class RenameTalkTrack < ActiveRecord::Migration[6.0]
  def change
    remove_column :talks, :track, :integer
    add_column :talks, :track_id, :integer
  end
end
