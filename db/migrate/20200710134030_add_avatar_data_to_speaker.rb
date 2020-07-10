class AddAvatarDataToSpeaker < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :avatar_data, :text
  end
end
