class AddOffset < ActiveRecord::Migration[7.0]
  def change
    add_column :talks, :start_offset, :integer, null: false, default: 0
    add_column :talks, :end_offset, :integer, null: false, default: 0
  end
end
