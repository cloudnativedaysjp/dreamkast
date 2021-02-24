class UpdateColumnsToTracks < ActiveRecord::Migration[6.0]
  def change
    rename_column :tracks, :movie_url, :video_id
    add_column :tracks, :video_platform, :string
  end
end
