class AddColumnsToChatMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_messages, :message_type, :integer
  end
end
