class MoveCheckInFlag < ActiveRecord::Migration[7.0]
  def change
    remove_column :profiles, :checked, :boolean
    add_column :orders, :checked, :boolean, null: false, default: false
  end
end
