class AddVisibleFlag < ActiveRecord::Migration[7.0]
  def change
    add_column :sponsor_types, :visible, :boolean, default: true
  end
end
