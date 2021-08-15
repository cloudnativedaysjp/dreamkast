class DeleteAccessLogs < ActiveRecord::Migration[6.0]
  def change
    drop_table :access_logs
  end
end
