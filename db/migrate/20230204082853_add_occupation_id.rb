class AddOccupationId < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :occupation_id, :integer, default: 34
  end
end
