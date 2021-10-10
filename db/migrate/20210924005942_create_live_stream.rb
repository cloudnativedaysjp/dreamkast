class CreateLiveStream < ActiveRecord::Migration[6.0]
  def change
    create_table :live_streams do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :track, null: true, foreign_key: true
      t.string :type
      t.json :params
    end
  end
end
