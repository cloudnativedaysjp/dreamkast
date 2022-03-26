class CreateTalkTimes < ActiveRecord::Migration[6.0]
  def change
    create_table :talk_times do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.integer :time_minutes

      t.timestamps
    end
    add_column :talks, :talk_time_id, :integer

  end
end
