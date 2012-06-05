class AddOriginToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :origin, :string
  end
end
