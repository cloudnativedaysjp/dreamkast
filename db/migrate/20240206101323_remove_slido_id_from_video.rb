class RemoveSlidoIdFromVideo < ActiveRecord::Migration[7.0]
  def change
    remove_column :videos, :slido_id, :string
  end
end
