class CreateProductCounts < ActiveRecord::Migration
  def change
    create_table :product_counts do |t|
      t.integer :event_id
      t.integer :product_id
      t.float :count
      t.boolean :is_box

      t.timestamps
    end
    add_index :product_counts, :event_id
    add_index :product_counts, :product_id

    add_index :product_counts, [:event_id, :product_id], :unique => true
  end
end
