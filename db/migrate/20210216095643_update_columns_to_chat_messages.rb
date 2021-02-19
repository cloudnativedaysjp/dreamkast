class UpdateColumnsToChatMessages < ActiveRecord::Migration[6.0]
  def change
    rename_column :chat_messages, :talk_id, :room_id
    remove_column :chat_messages, :booth_id
    add_column :chat_messages, :room_type, :string
  end
end
