class AddColumnsToSpeaker < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :email, :text
    add_column :speakers, :sub, :text
  end
end
