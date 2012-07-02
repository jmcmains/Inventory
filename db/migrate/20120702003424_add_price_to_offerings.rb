class AddPriceToOfferings < ActiveRecord::Migration
  def change
    add_column :offerings, :price, :float
  end
end
