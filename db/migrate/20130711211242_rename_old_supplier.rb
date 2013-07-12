class RenameOldSupplier < ActiveRecord::Migration
  def change
  	rename_column :events, :supplier, :oldsup
  end
end
