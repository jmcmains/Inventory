class Supplier < ActiveRecord::Base
	has_many :events
	has_many :supplier_prices, :foreign_key => "supplier_id", :dependent => :destroy
	has_many :products, through: :supplier_prices
	accepts_nested_attributes_for :supplier_prices, :reject_if => lambda { |attributes| attributes[:price].blank? || attributes[:quantity].blank? }, :allow_destroy => true
	has_many :ship_terms, through: :supplier_prices
	

	
  def self.search(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(all) do |combined_scope, word|
		    combined_scope.where('LOWER(name) LIKE ?',"%#{word.downcase}%")
		  end
  	else
  		return find(:all)
  	end
  end

end
