class AddAttrProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :number_of_employee_id, :integer, default: 12
    add_column :profiles, :annual_sales_id, :integer, default: 11
  end
end
