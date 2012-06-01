class AddSupplierToEvent < ActiveRecord::Migration
  def change
    add_column :events, :supplier, :string
  end
end
