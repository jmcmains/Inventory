class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
			t.integer :per_box
      t.timestamps
    end
  end
end
