class AddDefaultValueForMediaPackageChannels < ActiveRecord::Migration[6.0]
  def change
    change_column :media_package_channels, :channel_id, :string, default: ""
  end
end
