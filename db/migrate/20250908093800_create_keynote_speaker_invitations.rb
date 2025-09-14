class CreateKeynoteSpeakerInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :keynote_speaker_invitations do |t|
      t.references :conference, null: false, foreign_key: true
      t.references :speaker, foreign_key: true
      t.references :talk, foreign_key: true
      t.string :email, null: false
      t.string :name
      t.string :token, null: false
      t.datetime :invited_at, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.integer :created_by_id

      t.timestamps
    end

    add_index :keynote_speaker_invitations, :token, unique: true
    add_index :keynote_speaker_invitations, [:conference_id, :email]
  end
end