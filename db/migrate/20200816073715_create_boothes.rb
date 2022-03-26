class CreateBoothes < ActiveRecord::Migration[6.0]
  def change
    create_table :booths do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :sponsor, null: false, foreign_key: true, type: :bigint
      t.boolean :published

      t.timestamps
    end
  end
end
