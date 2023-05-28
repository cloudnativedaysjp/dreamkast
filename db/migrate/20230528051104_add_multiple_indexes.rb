class AddMultipleIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :conferences, :abbr
    add_index :conferences, [:abbr, :conference_status]
    add_index :proposal_item_configs, [:conference_id, :item_number]
    add_index :speakers, [:conference_id, :email], length: { email: 255 }
    add_index :talk_categories, :conference_id
    add_index :talk_difficulties, :conference_id
    add_index :talks_speakers, :speaker_id
    add_index :talks, :track_id
    add_index :tracks, :conference_id
  end
end
