class AddDeliveryMethodToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :delivery_method, :string
  end
end
