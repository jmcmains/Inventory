class Offering < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	require 'csv'
  has_many :orders, :foreign_key => "offering_id", :dependent => :destroy
  has_many :offering_products, :foreign_key => "offering_id", :dependent => :destroy
  has_many :products, through: :offering_products
  accepts_nested_attributes_for :offering_products, :reject_if => :all_blank, :allow_destroy => true
  validates :name, presence: true
  scope :with_n_products, lambda {|n| {:joins => :offering_products, :group => "offering_products.offering_id", :having => ["count(offering_id) = ?", n]}}

  def value
  	sql = ActiveRecord::Base.connection()
  	d=sql.execute("SELECT SUM(products.price * offering_products.quantity) as purchases FROM offerings INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (offerings.id = #{id})")
  	return d[0]["purchases"].to_f
  end
  
  def amazon_trend(origin)
  	y = amazon_sales_count(origin)["y"]
		d2 = amazon_sales_count(origin)["date"]
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
  
  def amazon_need(currentInventory,origin,leadTime)
		y = amazon_sales_count(origin)["y"]
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
  
  def amazon_sales_count(origin)
  	offers=Order.where(offering_id: id,origin: origin).sort_by(&:date).group_by { |o| o.date.beginning_of_week }
  	output=Hash.new
  	output["y"]=[]
  	output["date"]=[]
  	(offers.first[0]..Date.today.beginning_of_week).step(7).to_a.each_with_index do |date,i|
  		if !offers[date].blank?
  			output["y"][i]=offers[date].sum(&:quantity)
  		else
				output["y"][i]=0
			end
			output["date"][i]=date
  	end
  	return output
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
  
  def self.inventory(skus,location)
  	if location == "US"
merchant_id = "A272UC6GQ1EK7B"
marketplace_id = "ATVPDKIKX0DER"
aws_access_key_id = "AKIAIQHK2FY7EEQKBENA"
aws_secret_access_key = "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"
  	elsif location == "CA"
			merchant_id = "A15J4ZSOBGZ08"
			marketplace_id = "A2EUQ1WTGCTBG2"
			aws_access_key_id = "AKIAIZHQAZCXWAFW7FQA"
			aws_secret_access_key = "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"
  	end
  	inventory_client = MWS.fulfillment_inventory(marketplace_id: marketplace_id, merchant_id: merchant_id, aws_access_key_id: aws_access_key_id, aws_secret_access_key: aws_secret_access_key)
    resp = inventory_client.list_inventory_supply seller_skus: skus
    items = resp.xml['ListInventorySupplyResponse']['ListInventorySupplyResult']['InventorySupplyList']['member']
    if skus.count == 1
    	{items['SellerSKU'] => items['InStockSupplyQuantity'].to_i}
    else
		  items.inject Hash.new(0) do |inventory,item|
		    inventory.merge(item['SellerSKU'] => item['InStockSupplyQuantity'].to_i)
		  end
		end
  end
  
require 'peddler'
require 'active_support'
  def self.amazon(location)
  	if location == "US"
  		merchant_id = "A272UC6GQ1EK7B"
			marketplace_id = "ATVPDKIKX0DER"
			aws_access_key_id = "AKIAIQHK2FY7EEQKBENA"
			aws_secret_access_key = "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"
  	elsif location == "CA"
			merchant_id = "A15J4ZSOBGZ08"
			marketplace_id = "A2EUQ1WTGCTBG2"
			aws_access_key_id = "AKIAIZHQAZCXWAFW7FQA"
			aws_secret_access_key = "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"
  	end
		reports = MWS.reports(marketplace_id: marketplace_id, merchant_id: merchant_id, aws_access_key_id: aws_access_key_id, aws_secret_access_key: aws_secret_access_key)
		reports.request_report("_GET_AFN_INVENTORY_DATA_")
		report_list=Hash.from_xml(reports.get_report_list.body)
		inventory_report=""
		report_list["GetReportListResponse"]["GetReportListResult"]["ReportInfo"].each do |r|
			inventory_report=reports.get_report(r["ReportId"]).body if r["ReportType"] == "_GET_AFN_INVENTORY_DATA_"
		end
		i=0
		offer=[]
		CSV.parse(inventory_report, headers: true, col_sep: "\t") do |row|
			if row["Warehouse-Condition-code"] == "SELLABLE"
				offer[i]=Hash.new
				offer[i]["offering"]=Offering.where(sku: row["seller-sku"]).first
				offer[i]["inventory"]=row["Quantity Available"].to_f
				i=i+1
			end
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
