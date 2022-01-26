class CreateChatMessages < ActiveRecord::Migration[6.0]
  def self.up
    create_table :chat_messages do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :talk, null: true, foreign_key: true, type: :bigint
      t.belongs_to :booth, null: true, foreign_key: true, type: :bigint
      t.belongs_to :profile, null: true, foreign_key: true, type: :bigint
      t.belongs_to :speaker, null: true, foreign_key: true, type: :bigint

      t.string :body
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true

      # optional fields
      t.integer :depth, :null => false, :default => 0
      t.integer :children_count, :null => false, :default => 0
      t.timestamps

    end
  end

  def self.down
    drop_table :chat_messages
  end
end
