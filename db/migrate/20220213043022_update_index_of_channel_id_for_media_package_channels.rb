class UpdateIndexOfChannelIdForMediaPackageChannels < ActiveRecord::Migration[6.0]
  def up
    remove_index :media_package_channels, :channel_id
    add_index :media_package_channels, :channel_id
  end

  def down
    add_index :media_package_channels, :channel_id, unique: true
  end
end
