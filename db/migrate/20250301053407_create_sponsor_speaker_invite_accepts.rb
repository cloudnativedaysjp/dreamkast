class CreateSponsorSpeakerInviteAccepts < ActiveRecord::Migration[7.0]
  def change
    create_table :sponsor_speaker_invite_accepts do |t|
      t.references :sponsor_speaker_invite, null: false, foreign_key: true, index: { name: 'idx_spk_inv_accepts_on_invite' }
      t.references :conference, null: false, foreign_key: true
      t.references :sponsor, null: false, foreign_key: true
      t.references :sponsor_contact, null: false, foreign_key: true
      t.references :talk, null: false, foreign_key: true

      t.timestamps
    end

    add_index :sponsor_speaker_invite_accepts, [:conference_id, :sponsor_id, :talk_id], unique: true, name: 'idx_spk_inv_accepts_on_conf_spsr_talk'
  end
end
