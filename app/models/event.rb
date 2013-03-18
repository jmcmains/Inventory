class Event < ActiveRecord::Base
  has_many :product_counts, :foreign_key => "event_id", :dependent => :destroy
  has_many :products, through: :product_counts
  accepts_nested_attributes_for :product_counts, :reject_if => proc { |attributes| attributes['count'].blank?}, :allow_destroy => true
  scope :inventory, where(event_type: "Inventory")
  scope :unreceived, where(event_type: "Product Order", received: false)
  scope :received, where(event_type: "Product Order", received: true)
  scope :product_orders, where(event_type: "Product Order")

def per_unit_cost
	count = 0
	product_counts.each do |pc|
		if pc.is_box
			count = count + pc.count * Product.find(pc.product_id).per_box
		else
			count = count +pc.count
		end
	end
	return (additional_cost ? additional_cost : 0) /count
end



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

