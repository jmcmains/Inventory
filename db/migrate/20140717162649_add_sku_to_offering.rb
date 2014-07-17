class AddSkuToOffering < ActiveRecord::Migration
  def change
    add_column :offerings, :sku, :string
  end
end
