class AddSupplierIDtoEvent < ActiveRecord::Migration
  def change
  	add_column :events, :supplier_id, :integer
  end
end
