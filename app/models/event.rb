class Event < ActiveRecord::Base
  has_many :product_counts, :foreign_key => "event_id", :dependent => :destroy
  has_many :products, through: :product_counts
  accepts_nested_attributes_for :product_counts, :reject_if => :all_blank, :allow_destroy => true
  scope :inventory, where(event_type: "Inventory")
  scope :unreceived, where(event_type: "Product Order", received: false)
  scope :product_orders, where(event_type: "Product Order")

end
