class CreateSponsors < ActiveRecord::Migration[6.0]
  def change
    create_table :sponsors do |t|
      t.string :name
      t.text :description
      t.belongs_to :conference, null: false, foreign_key: true

      t.timestamps
    end
  end
end
