class CreateAnnouncementDeliveries < ActiveRecord::Migration[6.0]
  def change
    create_table :announcement_deliveries do |t|
      t.references :attendee_announcement, null: false, foreign_key: true, type: :bigint
      t.references :profile, null: false, foreign_key: true, type: :bigint
      t.string :email, null: false
      t.string :status, null: false
      t.string :provider_message_id
      t.text :last_error
      t.datetime :sent_at

      t.timestamps
    end

    add_index :announcement_deliveries, :email
    add_index :announcement_deliveries, :status
  end
end
