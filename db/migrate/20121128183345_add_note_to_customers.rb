class AddNoteToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :note, :string
  end
end
