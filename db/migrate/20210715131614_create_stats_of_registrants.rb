class CreateStatsOfRegistrants < ActiveRecord::Migration[6.0]
  def change
    create_table :stats_of_registrants do |t|
      t.belongs_to :conference, type: :bigint
      t.integer :number_of_registrants

      t.timestamps
    end
  end
end
