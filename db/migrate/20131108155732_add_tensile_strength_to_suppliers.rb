class AddTensileStrengthToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :tensile_strength, :float
  end
end
