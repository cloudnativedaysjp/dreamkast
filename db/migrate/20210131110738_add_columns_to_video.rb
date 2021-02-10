class AddColumnsToVideo < ActiveRecord::Migration[6.0]
  def change
    add_column :videos, :video_file_data, :text
  end
end
