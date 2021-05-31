class CreateProposalItems < ActiveRecord::Migration[6.0]
  def change
    add_column :talks, :expected_participants, :json
    add_column :talks, :execution_phases, :json

    create_table :proposal_item_configs do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.string :type
      t.integer :item_number
      t.string :label
      t.string :item_name
      t.json :params
    end
  end
end
