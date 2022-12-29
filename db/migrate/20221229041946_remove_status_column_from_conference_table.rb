class RemoveStatusColumnFromConferenceTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :conferences, :status, :integer
  end
end
