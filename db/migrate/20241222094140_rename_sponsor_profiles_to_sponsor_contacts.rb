class RenameSponsorProfilesToSponsorContacts < ActiveRecord::Migration[7.0]
  def change
    rename_table :sponsor_profiles, :sponsor_contacts
  end
end
