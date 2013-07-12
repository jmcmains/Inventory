class SupplierPrice < ActiveRecord::Base

  belongs_to :supplier, :class_name => "Supplier"
  belongs_to :ship_term, :class_name => "ShipTerm"
  belongs_to :product, :class_name => "Product"
  
  def product_name
  	product.try(:name)
  end
  
  def product_name=(name)
  	self.product=Product.find_or_create_by_name(name) if name.present?
  end
  
  def ship_term_term
  	ship_term.try(:term)
  end
  
  def ship_term_term=(term)
  	self.ship_term=ShipTerm.find_or_create_by_term(term) if term.present?
  end
end
