class ShipTerm < ActiveRecord::Base
  has_many :supplier_prices, :foreign_key => "ship_term_id", :dependent => :destroy
  has_many :suppliers, through: :supplier_prices
  
  def self.search(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(scoped) do |combined_scope, word|
		    combined_scope.where('LOWER(term) LIKE ?',"%#{word.downcase}%")
		  end
  	else
  		return find(:all)
  	end
  end
end
