class CreateBoothes < ActiveRecord::Migration[6.0]
  def change
    create_table :booths do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :sponsor, null: false, foreign_key: true
      t.boolean :published

      t.timestamps
    end
  end
end
