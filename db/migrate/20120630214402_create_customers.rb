class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :email
      t.float :total_cost
      t.string :payment_method
      t.string :transaction_number

      t.timestamps
    end
  end
end
