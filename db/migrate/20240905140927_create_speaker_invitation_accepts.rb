class CreateSpeakerInvitationAccepts < ActiveRecord::Migration[7.0]
  def change
    create_table :speaker_invitation_accepts do |t|
      t.references :speaker_invitation, null: false, foreign_key: true
      t.references :conference, null: false, foreign_key: true
      t.references :speaker, null: false, foreign_key: true
      t.references :talk, null: false, foreign_key: true

      t.timestamps
    end

    add_index :speaker_invitation_accepts, [:conference_id, :speaker_id, :talk_id], unique: true, name: 'index_speaker_invitation_accepts_on_conference_speaker_talk'

  end
end
