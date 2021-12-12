class AddColumnsToProposalItemConfigAndChangeType < ActiveRecord::Migration[6.0]
  def change
    add_column :proposal_item_configs, :key, :string
    add_column :proposal_item_configs, :value, :string
  end
end
