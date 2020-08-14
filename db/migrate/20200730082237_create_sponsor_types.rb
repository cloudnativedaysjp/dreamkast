class CreateSponsorTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :sponsor_types do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.string :name
      t.integer :order

      t.timestamps
    end

    create_table :sponsors_sponsor_types do |t|
      t.integer :sponsor_id
      t.integer :sponsor_type_id

      t.timestamps
    end
  end
end
