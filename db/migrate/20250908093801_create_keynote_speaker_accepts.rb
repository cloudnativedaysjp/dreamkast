class CreateKeynoteSpeakerAccepts < ActiveRecord::Migration[7.1]
  def change
    create_table :keynote_speaker_accepts do |t|
      t.references :keynote_speaker_invitation, null: false, foreign_key: true
      t.references :speaker, null: false, foreign_key: true
      t.references :talk, null: false, foreign_key: true

      t.timestamps
    end
  end
end