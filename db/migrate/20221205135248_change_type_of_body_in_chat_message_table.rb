class ChangeTypeOfBodyInChatMessageTable < ActiveRecord::Migration[7.0]
  def up
    change_column :chat_messages, :body, :text
  end

  def down
    change_column :chat_messages, :body, :string
  end
end
