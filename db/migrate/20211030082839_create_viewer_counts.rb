class CreateViewerCounts < ActiveRecord::Migration[6.0]
  def change
    create_table :viewer_counts do |t|
      t.integer :conference_id
      t.integer :track_id
      t.string :stream_type
      t.integer :talk_id
      t.integer :count

      t.timestamps
    end
    add_index :viewer_counts, :conference_id
    add_index :viewer_counts, :track_id
    add_index :viewer_counts, :talk_id
  end
end
