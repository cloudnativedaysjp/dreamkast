class SpeakerAnnouncementMiddles < ActiveRecord::Migration[6.0]
  def change
    create_table :speaker_announcement_middles do |t|
      t.references :speaker, null: false, foreign_key: true
      t.references :speaker_announcement, null: false, foreign_key: true
      t.timestamps
    end
  end
end
