class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.date :date
      t.string :event_type
      t.string :invoice
      t.date :received_date
      t.boolean :received
      t.timestamps
    end
  end
end
