class AddContactUrlToConference < ActiveRecord::Migration[7.0]
  def change
    add_column :conferences, :contact_url, :text
  end
end
