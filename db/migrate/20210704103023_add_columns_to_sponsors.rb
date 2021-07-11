class AddColumnsToSponsors < ActiveRecord::Migration[6.0]
  def change
    create_table :sponsor_profiles do |t|
      t.string :name
      t.string :sub
      t.string :email
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :sponsor, null: false

      t.timestamps
    end

    add_column :sponsors, :speaker_emails, :string
    add_column :talks, :sponsor_id, :integer
  end
end
