class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :contact_name
      t.string :email
      t.string :payment_terms

      t.timestamps
    end
  end
end
