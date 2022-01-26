class CreateSpeakerAnnouncements < ActiveRecord::Migration[6.0]
  def change
    create_table :speaker_announcements do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.datetime :publish_time, null: false
      t.text :body, null: false
      t.boolean :publish, default: false

      t.timestamps
    end
  end
end
