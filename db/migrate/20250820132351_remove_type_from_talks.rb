class RemoveTypeFromTalks < ActiveRecord::Migration[8.0]
  def change
    remove_column :talks, :type, :integer
  end
end
