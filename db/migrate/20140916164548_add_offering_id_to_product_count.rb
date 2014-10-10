class AddOfferingIdToProductCount < ActiveRecord::Migration
  def change
    add_column :product_counts, :offering_id, :integer
  end
end
