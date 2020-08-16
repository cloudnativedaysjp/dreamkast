class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.integer :talk_id
      t.string :site
      t.string :url
      t.boolean :on_air

      t.timestamps
    end
  end
end
