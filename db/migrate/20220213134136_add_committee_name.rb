class AddCommitteeName < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :committee_name, :string, null: false, default: "CloudNative Days Committee"
  end
end
