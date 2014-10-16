class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.string :name
      t.float :weight
      t.float :length
      t.float :width
      t.float :height

      t.timestamps
    end
  end
end
