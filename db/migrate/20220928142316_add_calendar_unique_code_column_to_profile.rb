class AddCalendarUniqueCodeColumnToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :calendar_unique_code, :string
  end
end
