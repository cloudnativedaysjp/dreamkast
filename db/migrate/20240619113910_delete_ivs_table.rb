class DeleteIvsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :live_streams
  end
end
