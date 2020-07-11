class AddRelationConferenceTalk < ActiveRecord::Migration[6.0]
  def change
    add_column :talks, :conference_id, :integer
    add_column :talks, :conference_day_id, :integer
  end
end
