class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
			t.string :order_number
      t.date :date
			t.integer :offering_id
			t.integer :quantity
      t.timestamps
    end
  end
end
