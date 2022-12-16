class AddIndexToRegisteredTalks < ActiveRecord::Migration[7.0]
  def change
    add_index :registered_talks, :profile_id
    add_index :registered_talks, :talk_id
  end
end
