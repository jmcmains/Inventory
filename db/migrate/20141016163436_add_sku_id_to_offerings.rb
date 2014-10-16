class AddSkuIdToOfferings < ActiveRecord::Migration
  def change
    add_column :offerings, :sku_id, :integer
  end
end
