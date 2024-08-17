class DeleteLogsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :access_logs
  end
end
