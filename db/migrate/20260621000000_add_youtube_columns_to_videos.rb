class AddYoutubeColumnsToVideos < ActiveRecord::Migration[8.0]
  def change
    add_column :videos, :youtube_video_id, :string
    add_column :videos, :youtube_upload_status, :integer, default: 0, null: false
    add_column :videos, :youtube_uploaded_at, :datetime
    add_column :videos, :youtube_upload_error, :text
  end
end
