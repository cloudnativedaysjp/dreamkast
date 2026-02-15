class CreateAttendeeAnnouncementMiddles < ActiveRecord::Migration[6.0]
  def change
    create_table :attendee_announcement_middles do |t|
      t.references :profile, null: false, foreign_key: true, type: :bigint
      t.references :attendee_announcement, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
