class RemovePcIndex < ActiveRecord::Migration
  def up
  	remove_index :product_counts, [:event_id, :product_id]
  end

  def down
  	add_index :product_counts, [:event_id, :product_id], :unique => true
  end
end
