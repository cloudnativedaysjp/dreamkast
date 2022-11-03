class AddCheckedIn < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :checked, :boolean, null: false, default: false
  end
end
