class AddUltimateElongationToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :ultimate_elongation, :float
  end
end
