class CreateSupplierPrices < ActiveRecord::Migration
  def change
    create_table :supplier_prices do |t|
      t.date :date
      t.integer :supplier_id
      t.integer :product_id
      t.integer :ship_term_id
      t.float :quantity
      t.float :price

      t.timestamps
    end
  end
end
