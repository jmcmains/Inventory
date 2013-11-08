class AddCommentsToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :comments, :string
  end
end
