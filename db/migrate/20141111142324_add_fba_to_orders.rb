class AddFbaToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :fba, :boolean, default: false
  end
end
