class AddAttrToFormItems < ActiveRecord::Migration[7.0]
  def change
    add_column :form_items, :attr, :string
  end
end
