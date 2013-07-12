class CreateShipTerms < ActiveRecord::Migration
  def change
    create_table :ship_terms do |t|
      t.string :term

      t.timestamps
    end
  end
end
