class Event < ActiveRecord::Base
  has_many :product_counts, :foreign_key => "event_id", :dependent => :destroy
  has_many :products, through: :product_counts
  accepts_nested_attributes_for :product_counts, :reject_if => :check_product_count , :allow_destroy => true
  scope :inventory, where(event_type: "Inventory")
  scope :unreceived, where(event_type: "Product Order", received: false)
  scope :product_orders, where(event_type: "Product Order")

protected

    def check_product_count(product_count_attr)

      if product_count_attr['count'].blank?
      	rval ||= true
      else
      	rval ||= false
      end
      
      return rval
    end
end
