class AddConferenceBrief < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :brief, :string
  end
end
