class AddTypeColumnToTalks < ActiveRecord::Migration[7.0]
  def up

    create_table :talk_types, id: :string do |t|
      t.timestamps
    end

    Talk::Type::KLASSES.each do |klass|
      Talk::Type.seed({id: klass.name})
    end

    add_column :talks, :type, :string, after: :id, collation: 'utf8mb4_0900_ai_ci'

    Talk.where('sponsor_id IS NOT NULL').update_all(type: 'SponsorSession')
    Talk.where('abstract = "intermission"').update_all(type: 'Intermission')
    Talk.where('sponsor_id IS NULL').where('abstract != "intermission"').update_all(type: 'Session')
    Talk.reset_column_information

    change_column_null :talks, :type, false
    add_foreign_key :talks, :talk_types, column: :type, primary_key: :id
  end

  def down
    remove_foreign_key :talks, :talk_types
    remove_column :talks, :type
    drop_table :talk_types
  end
end
