class ModifyVideoRegistrationsForNextCloud < ActiveRecord::Migration[7.0]
  def up
    add_column :video_registrations, :statistics, :json, null: false
    add_column :video_registrations, :created_at, :datetime, null: true
    add_column :video_registrations, :updated_at, :datetime, null: true
    VideoRegistration.update_all(created_at: Time.current)
    VideoRegistration.update_all(updated_at: Time.current)
    change_column :video_registrations, :created_at, :datetime, null: false
    change_column :video_registrations, :updated_at, :datetime, null: false
  end

  def down
    remove_column :video_registrations, :statistics
    remove_column :video_registrations, :created_at
    remove_column :video_registrations, :updated_at
  end
end
