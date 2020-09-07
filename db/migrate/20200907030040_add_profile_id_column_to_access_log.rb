class AddProfileIdColumnToAccessLog < ActiveRecord::Migration[6.0]
  def change
    add_column :access_logs, :profile_id, :integer
  end
end
