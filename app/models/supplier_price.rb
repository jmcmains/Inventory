class SupplierPrice < ActiveRecord::Base
	
  belongs_to :supplier, :class_name => "Supplier"
  belongs_to :ship_term, :class_name => "ShipTerm"
  belongs_to :product, :class_name => "Product"
  
  def product_name
  	product.try(:name)
  end
  
  def product_name=(name)
  	self.product=Product.where(name: name).first_or_create if name.present?
  end
  
  def supplier_name
  	supplier.try(:name)
  end
  
  def supplier_name=(name)
  	self.supplier=Supplier.where(name: name).first_or_create if name.present?
  end
  
  def ship_term_term
  	ship_term.try(:term)
  end
  
  def ship_term_term=(term)
  	self.ship_term=ShipTerm.where(term: term).first_or_create if term.present?
  end
end
