class AddDefaultValueForMediaPackageChannels < ActiveRecord::Migration[6.0]
  def up
    change_column :media_package_channels, :channel_id, :string, default: ""
  end
end
