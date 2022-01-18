class AddIndexTalksConferenceId < ActiveRecord::Migration[6.0]
  def change
    add_index :talks, conference_id
  end
end
