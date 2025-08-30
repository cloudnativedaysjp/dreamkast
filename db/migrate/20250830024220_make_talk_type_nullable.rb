class MakeTalkTypeNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :talks, :type, true
  end
end