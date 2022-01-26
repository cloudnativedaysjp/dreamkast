class CreateVideoRegistrations < ActiveRecord::Migration[6.0]
  def change
    create_table :video_registrations do |t|
      t.belongs_to :talk, null: false, foreign_key: true, type: :bigint
      t.string :url
      t.integer :status, null: false, default: 0
    end
  end
end
