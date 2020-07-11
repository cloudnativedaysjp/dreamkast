class AddAvatarDataToSpeaker < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :avatar_data, :text
    drop_table :active_storage_attachments
    drop_table :active_storage_blobs
  end
end
