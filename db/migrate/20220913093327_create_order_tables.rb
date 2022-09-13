class CreateOrderTables < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.belongs_to :profile, null: false, foreign_key: true, type: :bigint
      t.belongs_to :order, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end

    create_table :cancel_orders do |t|
      t.belongs_to :order, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end

    create_table :tickets do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.string :title, null: false
      t.text :description, null: false
      t.integer :price, null: false
      t.integer :stock, null: false

      t.timestamps
    end

    create_table :orders_tickets do |t|
      t.references :order, null: false, foreign_key: true, type: :bigint
      t.references :ticket, null: false, foreign_key: true, type: :bigint
      t.timestamps
    end
  end
end
