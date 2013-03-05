class AddAdditionalCostToEvents < ActiveRecord::Migration
  def change
    add_column :events, :additional_cost, :float
  end
end
