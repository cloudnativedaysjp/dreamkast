class CreateTalks < ActiveRecord::Migration[6.0]
  def change
    create_table :talks do |t|
      t.string :title
      t.string :abstract
      t.string :movie_url
      t.string :track
      t.time :start_time
      t.time :start_time
      t.int :difficulty_id
      t.int :category_id

      t.timestamps
    end
  end
end
