class AddTalkIdColumnsToLiveStreams < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :live_streams, :talk, null: true, foreign_key: true
  end
end
