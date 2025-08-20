class CreateTalkAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :talk_attributes do |t|
      t.string :name, null: false, limit: 50
      t.string :display_name, null: false, limit: 100
      t.text :description
      t.boolean :is_exclusive, default: false, null: false
      
      t.timestamps
      
      t.index :name, unique: true
      t.index :is_exclusive
    end
  end
end
