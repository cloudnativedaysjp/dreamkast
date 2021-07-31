class AddNameMotherTongueColumnToSpeakers < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :name_mother_tongue, :string
  end
end
