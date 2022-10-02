class AddUniqueCodeColumnToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :unique_code, :string
  end
end
