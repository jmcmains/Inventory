class AddDiscountToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :discount, :string
    rename_column :products, :weight_lbs, :weight
    remove_column :products, :weight_oz
  end
end
