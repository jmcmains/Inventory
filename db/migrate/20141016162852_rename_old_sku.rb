class RenameOldSku < ActiveRecord::Migration
  def change
  	rename_column :offerings, :sku, :oldsku
  end
end
