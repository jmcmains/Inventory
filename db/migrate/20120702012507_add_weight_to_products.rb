class AddWeightToProducts < ActiveRecord::Migration
  def change
    add_column :products, :weight_lbs, :float
    add_column :products, :weight_oz, :float
  end
end
