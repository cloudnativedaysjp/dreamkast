class CreateAdminProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_profiles do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint

      t.string :sub
      t.string :email
      t.string :name
      t.string :twitter_id
      t.string :github_id
      t.text :avatar_data

      t.timestamps
    end
  end
end
