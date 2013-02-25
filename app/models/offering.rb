class Offering < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
  has_many :orders, :foreign_key => "offering_id"
  has_many :offering_products, :foreign_key => "offering_id", :dependent => :destroy
  has_many :products, through: :offering_products
  accepts_nested_attributes_for :offering_products, :reject_if => :all_blank, :allow_destroy => true
  validates :name, :replace, presence: true
  
  def replace
  
  end
  def self.search(search,price)
  	if search
			words = search.to_s.strip.split
		  words.inject(scoped) do |combined_scope, word|
		  	if price
		    	combined_scope.where('LOWER(name) LIKE ? AND price > 0',"%#{word.downcase}%")
		    else
		    	combined_scope.where('LOWER(name) LIKE ?',"%#{word.downcase}%")
		    end
		  end
  	else
  		return find(:all)
  	end
  end
  
	def total_weight
		sql = connection()
		d=sql.execute("SELECT SUM(products.weight * offering_products.quantity) FROM offerings INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (offerings.id = #{self.id})")
		if Rails.env.production?
			return d.map { |a| a["sum"].to_f }[0]
		else
			return d[0][0]
		end
	end
end
