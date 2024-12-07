class AddUsersTable < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.transaction do
      create_table :users do |t|
        t.string :sub
        t.string :email
        t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
        t.timestamps
      end

      add_reference :profiles, :user, foreign_key: true

      Profile.all.each do |profile|
        user = User.create!(id: profile.id, sub: profile.sub, email: profile.email, conference: profile.conference)
        profile.update!(user: user)
      end

      remove_column :profiles, :sub, :string
      remove_column :profiles, :email, :string
      change_column_null :profiles, :user_id, false
    end
  end
end
