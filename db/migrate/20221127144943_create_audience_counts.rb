class CreateAudienceCounts < ActiveRecord::Migration[7.0]
  def change
    create_table :audience_counts do |t|
      t.string :sub
      t.integer :min
      t.string :track_name
      t.integer :talk_id
      t.string :talk_name

      t.timestamps
    end
    add_index :audience_counts, :talk_id
  end
end
