class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.string :title
      t.string :url
      t.text :description

      t.timestamps
    end
  end
end
