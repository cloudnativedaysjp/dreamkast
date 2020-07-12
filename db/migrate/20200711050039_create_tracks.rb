class CreateTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :tracks do |t|
      t.integer :number
      t.string :name
      t.string :movie_url
      t.integer :conference_id
      t.timestamps
    end
  end
end
