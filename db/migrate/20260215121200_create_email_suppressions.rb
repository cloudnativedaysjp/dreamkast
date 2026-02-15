class CreateEmailSuppressions < ActiveRecord::Migration[6.0]
  def change
    create_table :email_suppressions do |t|
      t.string :email, null: false
      t.string :reason, null: false
      t.string :source, null: false
      t.string :status, null: false, default: 'active'
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false

      t.timestamps
    end

    add_index :email_suppressions, :email, unique: true
  end
end
