class ProductCount < ActiveRecord::Base
  belongs_to :event, :class_name => "Event"
	belongs_to :product, :class_name => "Product"

	def product_name
  	product.try(:name)
  end
  
  def product_name=(name)
  	self.product = Product.find_or_create_by_name(name) if name.present?
  end
  
  def box_count=(bcount)
  	if self.count.blank?
  		self.count = ((bcount.blank? ? 0 : bcount) * self.product.per_box)
  	else
  		self.count += ((bcount.blank? ? 0 : bcount) * self.product.per_box)
  	end
  end
  
  def peice_count=(pcount)
		if self.count.blank?
  		self.count = (pcount.blank? ? 0 : pcount)
  	else
  		self.count += (pcount.blank? ? 0 : pcount)
  	end
  end
  
  def product_image
  	product.try(:imloc)
  end
  
  def product_image=(imloc)
  	self.product = Product.find_or_create_by_imloc(imloc) if imloc.present?
  end
  
  def product_description
  	product.try(:description)
  end
  
  def product_description=(description)
  	self.product = Product.find_or_create_by_description(description) if description.present?
  end
  
  def product_description
  	product.try(:description)
  end
  
  def product_description=(description)
  	self.product = Product.find_or_create_by_description(description) if description.present?
  end
end
