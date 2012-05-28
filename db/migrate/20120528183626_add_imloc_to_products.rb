class AddImlocToProducts < ActiveRecord::Migration
  def change
    add_column :products, :imloc, :string
  end
end
