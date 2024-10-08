class AddScannerProfileIdColumnsToCheckIns < ActiveRecord::Migration[7.0]
  def change
    add_column :check_in_conferences, :scanner_profile_id, :bigint, null: true
    add_column :check_in_talks, :scanner_profile_id, :bigint, null: true
  end
end
