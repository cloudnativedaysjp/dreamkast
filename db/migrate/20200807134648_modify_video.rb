class ModifyVideo < ActiveRecord::Migration[6.0]
  def change
    add_column :videos, :video_id, :string
    add_column :videos, :slido_id, :string
  end
end
