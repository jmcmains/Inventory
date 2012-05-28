class CreateOfferingProducts < ActiveRecord::Migration
  def change
    create_table :offering_products do |t|
      t.integer :offering_id
      t.integer :product_id
      t.integer :quantity

      t.timestamps
    end
    add_index :offering_products, :offering_id
    add_index :offering_products, :product_id

    add_index :offering_products, [:offering_id, :product_id], :unique => true
  end
end
