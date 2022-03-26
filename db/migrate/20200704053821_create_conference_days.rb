class CreateConferenceDays < ActiveRecord::Migration[6.0]
  def change
    create_table :conference_days do |t|
      t.date :date
      t.time :start_time
      t.time :end_time
      t.belongs_to :conference, type: :bigint

      t.timestamps
    end
  end
end
