class CreateTalkTypes < ActiveRecord::Migration[8.0]
  def change
    # add_column :talk_types, :name, :string, null: false, limit: 50
    add_column :talk_types, :display_name, :string, null: false, limit: 100
    add_column :talk_types, :description, :text
    add_column :talk_types, :is_exclusive, :boolean, default: false, null: true
    add_index :talk_types, :is_exclusive
  end
end