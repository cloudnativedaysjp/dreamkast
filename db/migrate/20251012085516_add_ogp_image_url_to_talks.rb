class AddOgpImageUrlToTalks < ActiveRecord::Migration[8.0]
  def change
    add_column :talks, :ogp_image_url, :string
  end
end
