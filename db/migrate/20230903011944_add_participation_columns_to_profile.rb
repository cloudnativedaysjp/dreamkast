class AddParticipationColumnsToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :participation, :string
  end
end
