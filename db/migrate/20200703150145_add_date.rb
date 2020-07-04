class AddDate < ActiveRecord::Migration[6.0]
  def change
    add_column :talks, :date, :date
  end
end
