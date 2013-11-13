class Offering < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
  has_many :orders, :foreign_key => "offering_id", :dependent => :destroy
  has_many :offering_products, :foreign_key => "offering_id", :dependent => :destroy
  has_many :products, through: :offering_products
  accepts_nested_attributes_for :offering_products, :reject_if => :all_blank, :allow_destroy => true
  validates :name, presence: true
  
   
  def amzus
  	orders.where(origin: "Amazon US")
  end
  
  def amzca
  	orders.where(origin: "Amazon Canada")
  end
  
  def website
  	orders.where(origin: "Website")
  end
  
  def buy
  	orders.where(origin: "Buy")
  end
  
  def phone
  	orders.where(origin: "phone or email")
  end
  
  def ebay
 	 orders.where(origin: "EBay")
  end
  
  def self.search(search,price)
  	if search
			words = search.to_s.strip.split
		  words.inject(all) do |combined_scope, word|
		  	if price
		    	combined_scope.includes(:products).where('products.id NOT NULL AND LOWER(offerings.name) LIKE ? AND price > 0',"%#{word.downcase}%").references(:products)
		    else	
					combined_scope.includes(:products).where('products.id IS NOT NULL AND LOWER(offerings.name) LIKE ?',"%#{word.downcase}%").references(:products)
		    end
		  end
  	else
  		return find(:all)
  	end
  end
  
	def total_weight
		sql = ActiveRecord::Base.connection()
		d=sql.execute("SELECT SUM(products.weight * offering_products.quantity) FROM offerings INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (offerings.id = #{self.id})")
		if Rails.env.production?
			return d.map { |a| a["sum"].to_f }[0]
		else
			return d[0][0]
		end
	end
end
