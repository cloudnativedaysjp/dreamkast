class DeleteDateColumnFromTalks < ActiveRecord::Migration[6.0]
  def change
    remove_column :talks, :date, :date
  end
end
