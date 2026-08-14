class AddMediaConvertJobIdToVideos < ActiveRecord::Migration[8.0]
  def change
    add_column :videos, :media_convert_job_id, :string
  end
end
