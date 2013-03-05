class AddPriceToProductCounts < ActiveRecord::Migration
  def change
    add_column :product_counts, :price, :float
  end
end
