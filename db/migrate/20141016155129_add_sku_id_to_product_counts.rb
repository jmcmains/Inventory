class AddSkuIdToProductCounts < ActiveRecord::Migration
  def change
    add_column :product_counts, :sku_id, :integer
  end
end
