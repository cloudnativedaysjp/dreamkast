class CreateAnnouncementDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table(:announcement_deliveries) do |t|
      t.bigint(:announcement_id, null: false)
      t.bigint(:profile_id)
      t.string(:email, null: false)
      t.string(:status, null: false, default: 'queued')
      t.string(:provider_message_id)
      t.text(:last_error)

      t.timestamps
    end

    add_index(:announcement_deliveries, [:announcement_id, :status])
    add_index(:announcement_deliveries, :announcement_id)
    add_index(:announcement_deliveries, :profile_id)

    add_foreign_key(:announcement_deliveries, :announcements, on_delete: :cascade)
    add_foreign_key(:announcement_deliveries, :profiles, on_delete: :nullify)
  end
end
