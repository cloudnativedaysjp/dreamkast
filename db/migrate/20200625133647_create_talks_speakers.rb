class CreateTalksSpeakers < ActiveRecord::Migration[6.0]
  def change
    create_table :talks_speakers do |t|
      t.integer :talk_id
      t.integer :speaker_id

      t.timestamps
    end
  end
end
