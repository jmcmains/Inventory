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
  		self.count = ((bcount.to_f.blank? ? 0 : bcount.to_f) * (self.product.per_box.blank? ? 1 : self.product.per_box))
  	else
  		self.count += ((bcount.to_f.blank? ? 0 : bcount.to_f) * (self.product.per_box.blank? ? 1 : self.product.per_box))
  	end
  end
  
  def box_count
  	if is_box
  		count
  	else
  		(self.count/(self.product.per_box.blank? ? 1 : self.product.per_box)).floor
  	end
  end
  
  def piece_count=(pcount)
		if self.count.blank?
  		self.count = (pcount.to_f.blank? ? 0 : pcount.to_f)
  	else
  		self.count += (pcount.to_f.blank? ? 0 : pcount.to_f)
  	end
  end
  
  def piece_count
  	if is_box
  		0
  	else
  		self.count-((self.count/(self.product.per_box.blank? ? 1 : self.product.per_box)).floor*(self.product.per_box.blank? ? 1 : self.product.per_box))
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
