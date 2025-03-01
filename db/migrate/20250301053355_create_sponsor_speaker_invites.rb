class CreateSponsorSpeakerInvites < ActiveRecord::Migration[7.0]
  def change
    create_table :sponsor_speaker_invites do |t|
      t.references :talk, null: false, foreign_key: true
      t.references :conference, null: false, foreign_key: true
      t.references :sponsor, null: false, foreign_key: true
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
