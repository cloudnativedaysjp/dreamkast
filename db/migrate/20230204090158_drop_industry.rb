class DropIndustry < ActiveRecord::Migration[7.0]
  def change
    drop_table :industries
  end
end
