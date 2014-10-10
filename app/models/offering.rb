class Offering < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	require 'csv'
  has_many :orders, :foreign_key => "offering_id", :dependent => :destroy
  has_many :offering_products, :foreign_key => "offering_id", :dependent => :destroy
  has_many :products, through: :offering_products
  accepts_nested_attributes_for :offering_products, :reject_if => :all_blank, :allow_destroy => true
  validates :name, presence: true
  scope :with_n_products, lambda {|n| {:joins => :offering_products, :group => "offering_products.offering_id", :having => ["count(offering_id) = ?", n]}}

require 'peddler'
require 'active_support'

  def value
  	sql = ActiveRecord::Base.connection()
  	d=sql.execute("SELECT SUM(products.price * offering_products.quantity) as purchases FROM offerings INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (offerings.id = #{id})")
  	return d[0]["purchases"].to_f
  end
  
  def amazon_trend(sku,origin)
  	y = amazon_sales_count(sku,origin)["y"]
		d2 = amazon_sales_count(sku,origin)["date"]
		output=Hash.new
  	output["m"]=[]
  	output["b"]=[]
		if !d2.blank?
			x = []
			d2.each_with_index do |d,i|
				x[i]=((d-d2[0])/7).to_f
			end
			lineFit = LineFit.new
			lineFit.setData(x,y)
			output["b"], output["m"] = lineFit.coefficients
		else
			output["m"] = 0
			output["b"] = 0
		end
		return output
  end
  
  def self.amazon_need(sku,currentInventory,origin,leadTime)
		y = self.amazon_sales_count(sku,origin)["y"]
		(0..y.length-1).each do |n|
			y[n] = 0 if !y[n]
		end
		x =(1..y.length).to_a
		if y.count > 1
			lineFit = LineFit.new
			lineFit.setData(x,y)
			b, m = lineFit.coefficients
			sigma = lineFit.sigma
		else
			b=m=sigma=0
		end
		leadTimeWeeks = (leadTime/7.0).ceil
		averageNetInventory = 2*sigma*Math.sqrt(leadTimeWeeks)
		weeks = (0..leadTimeWeeks).map { |w| w+y.length }
		predictedDemand = weeks.map { |x1| m*x1+b }
		predictedDemand2= predictedDemand.sum - predictedDemand[0]
		needed = averageNetInventory+predictedDemand2 - (currentInventory)
		return needed
	end
  
  def self.amazon_sales_count(sku,origin)
  	sql = ActiveRecord::Base.connection()
  	d=sql.execute("SELECT SUM(orders.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (offerings.sku = '#{sku}') AND (orders.origin = '#{origin}') GROUP BY year, week ORDER BY year, week ")
  	data=Hash.new()
  	y=d.map { |a| a["sum"].to_i }
		dates = d.map { |a| Date.commercial(a["year"].to_i,a["week"].to_i,1) if !a['year'].nil? && !a['week'].nil? }
		if y.count > 0
			if dates.last >= Date.today.beginning_of_week-1
				dates.pop
				y.pop	
			end
		end
		data["dates"]=Hash.new()
		data["y"]=Hash.new()
		if !dates.blank?
			data["dates"]=((dates.first..(Date.today.beginning_of_week-7)).step(7)).to_a
			data["y"]=Array.new(data["dates"].length,0)
			dates.each_with_index do |d,i|
				data["y"][data["dates"].index(d)]=y[i]
			end
		end
		return data
  end
  
  def self.search_sku(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(all) do |combined_scope, word|
					combined_scope.where('LOWER(sku) LIKE ?',"%#{word.downcase}%")
		  end
  	else
  		return all
  	end
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
  		return all
  	end
  end
  def self.amazon_id(location)
		if location == "Amazon US"
			output = {merchant_id: "A272UC6GQ1EK7B",marketplace_id: "ATVPDKIKX0DER", aws_access_key_id: "AKIAIQHK2FY7EEQKBENA", aws_secret_access_key: "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"}
		elsif location == "Amazon Canada"
			output = {merchant_id: "A15J4ZSOBGZ08", marketplace_id: "A2EUQ1WTGCTBG2", aws_access_key_id: "AKIAIZHQAZCXWAFW7FQA", aws_secret_access_key: "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"}
		end
		return output
  end
  
  def self.inventory_client(location)
  	data=amazon_id(location)
  	return MWS.fulfillment_inventory(data)
  end
  
  def self.report(location)
  	data=amazon_id(location)
  	return MWS.fulfillment_inventory(data)
  end
  
  def self.inventory(skus,location)
  	ic=inventory_client(location)
    resp = ic.list_inventory_supply seller_skus: skus
    items = resp.xml['ListInventorySupplyResponse']['ListInventorySupplyResult']['InventorySupplyList']['member']
    if items.class == Array
    	items=items.reject { |a| a["ASIN"].blank? }
    	if items.length == 1
    		{items[0]['SellerSKU'] => items[0]['TotalSupplyQuantity'].to_i}
		  else
				items.inject Hash.new(0) do |inv,item|
				  	inv.merge(item['SellerSKU'] => item['TotalSupplyQuantity'].to_i)
				end
			end
    elsif items.class == Hash
    	{items['SellerSKU'] => items['TotalSupplyQuantity'].to_i}
    end
    
  end
  
  def self.amazon(location)
  	skus=Offering.all.map(&:sku).uniq.compact.reject { |c| c.empty? }
  	offer = Hash.new()
  	if skus.length > 50
  		count=(skus.length/50.0).ceil
  		(1..count).to_a.each do |i|
  			offer=offer.merge(inventory(skus[((i-1)*50)..[((i*50)-1),skus.length].min],location))
  		end
  	else
  		offer=inventory(skus,location)
  	end
		return offer
  end
  
  def self.add_price(file)
  	offs ={}
  	prices={}
  	csv_text = File.read(file)
  	i=0
		CSV.parse(csv_text, headers: true, col_sep: "\t") do |row|
			offs[i]=row[0]
  		prices[i]= row[1]
  		i=i+1
		end
		return prices
  end
  
	def total_weight
		sql = ActiveRecord::Base.connection()
		d=sql.execute("SELECT SUM(products.weight * offering_products.quantity) FROM offerings INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (offerings.id = #{self.id})")
		return d.map { |a| a["sum"].to_f }[0]
	end
end
