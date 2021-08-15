class UpdateColumnsToChatMessages < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key :chat_messages, :talks
    remove_index :chat_messages, :talk_id
    remove_reference :chat_messages, :talk, index: true

    remove_foreign_key :chat_messages, :booths
    remove_index :chat_messages, :booth_id
    remove_reference :chat_messages, :booth, index: true

    add_column :chat_messages, :room_type, :string
    add_column :chat_messages, :room_id, :bigint
  end

  def down
    remove_column :chat_messages, :room_id

    add_column :chat_messages, :booth_id, :bigint
    add_column :chat_messages, :talk_id, :bigint
  end
end
