class CreateProfileSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :profile_surveys do |t|
      t.string :sub
      t.datetime :filled_at
      t.string :url
      t.string :generation
      t.string :industry
      t.string :department
      t.string :occupation
      t.string :position

      t.timestamps
    end
  end
end
