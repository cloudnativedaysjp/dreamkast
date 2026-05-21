class RemoveOffsetFromTalks < ActiveRecord::Migration[7.0]
  def change
    remove_column :talks, :start_offset, :integer, null: false, default: 0
    remove_column :talks, :end_offset, :integer, null: false, default: 0
  end
end
