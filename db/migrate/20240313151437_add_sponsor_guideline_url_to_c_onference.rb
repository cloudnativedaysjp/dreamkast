class AddSponsorGuidelineUrlToCOnference < ActiveRecord::Migration[7.0]
  def change
    add_column :conferences, :sponsor_guideline_url, :text
  end
end
