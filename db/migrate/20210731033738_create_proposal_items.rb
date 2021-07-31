class CreateProposalItems < ActiveRecord::Migration[6.0]
  def change
    add_column :proposal_item_configs, :description, :text

    create_table :proposal_items do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :proposal_item_config, null: false
      t.belongs_to :talk, null: false
      t.string :label
      t.json :params
    end
  end
end
