class FeatureSponsorContactInvite < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.transaction do
      create_table :sponsor_contact_invites do |t|
        t.references :conference, null: false, foreign_key: true
        t.references :sponsor, null: false, foreign_key: true
        t.string :email, null: false
        t.string :token, null: false
        t.datetime :expires_at, null: false
      end

      create_table :sponsor_contact_invite_accepts do |t|
        t.references :sponsor_contact_invite, null: false, foreign_key: true, index: { name: 'index_sponsor_contact_invite_accepts_on_invitation_id' }
        t.references :conference, null: false, foreign_key: true
        t.references :sponsor, null: false, foreign_key: true
        t.references :sponsor_contact, null: false, foreign_key: true

        t.timestamps
      end

      remove_column :sponsors, :speaker_emails, :string
    end
  end
end
