class CreateVideoRegistrationStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :video_registration do |t|
      t.belongs_to :talk, null: false, foreign_key: true
      t.string :url
      t.integer :status, null: false, default: 0
    end
  end
end
