class AddDisplayToProducts < ActiveRecord::Migration
  def change
    add_column :products, :display, :boolean, default: true
  end
end
