class AddShoreADurometerToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :shore_a_durometer, :float
  end
end
