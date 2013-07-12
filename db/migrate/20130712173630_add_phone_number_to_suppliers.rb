class AddPhoneNumberToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :phone_number, :string
  end
end
