class CreateAnnouncements < ActiveRecord::Migration[6.0]
  def change
    create_table :announcements do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.datetime :publish_time
      t.text :body
      t.boolean :publish
    end
  end
end
