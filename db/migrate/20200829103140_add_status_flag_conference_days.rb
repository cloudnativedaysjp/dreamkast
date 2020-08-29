class AddStatusFlagConferenceDays < ActiveRecord::Migration[6.0]
  def change
    add_column :conference_days, :internal, :boolean, null: false, default: false
  end
end
