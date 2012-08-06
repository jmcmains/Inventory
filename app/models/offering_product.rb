class OfferingProduct < ActiveRecord::Base
  belongs_to :offering, :class_name => "Offering"
  belongs_to :product, :class_name => "Product"
  
  def product_name
  	product.try(:name)
  end
  
  def product_name=(name)
  	self.product = Product.find_or_create_by_name(name) if name.present?
  end
end
