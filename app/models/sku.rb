class Sku < ActiveRecord::Base
	has_many :offerings, :foreign_key => "sku_id", :dependent => :destroy
	has_many :product_counts, :foreign_key => "sku_id", :dependent => :destroy
	has_many :events, through: :product_counts
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
  
  def cogs
  	start_date=1.year.ago
  	end_date=Date.today
  	total_cogs=0
  	offerings.first.offering_products.each do |op|
  		cost=op.product.cogs(start_date,end_date)
  		part = cost[:purchases] > 0 ? (cost[:value]/cost[:purchases]) : 0
  		total_cogs=total_cogs+op.quantity*part
  	end
  	return total_cogs
  end
  
  def self.amazon_id(location)
		if location == "Amazon US"
			output = {merchant_id: ENV["amazon_us_merchant_id"],marketplace_id: ENV["amazon_us_marketplace_id"], aws_access_key_id: ENV["amazon_us_aws_access_key_id"], aws_secret_access_key: ENV["amazon_us_aws_secret_access_key"]}
		elsif location == "Amazon Canada"
			output = {merchant_id: ENV["amazon_ca_merchant_id"],marketplace_id: ENV["amazon_ca_marketplace_id"], aws_access_key_id: ENV["amazon_ca_aws_access_key_id"], aws_secret_access_key: ENV["amazon_ca_aws_secret_access_key"]}
		end
		return output
  end
  
  def get_trend
		sql = ActiveRecord::Base.connection()
		data= {}
		data['y'] = []
		data['dates'] = []
		y=[]
		dates=[]
		d=sql.execute("SELECT SUM(orders.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id WHERE (offerings.sku_id = #{id}) GROUP BY year, week ORDER BY year, week ")
			y=d.map { |a| a["sum"].to_i }
			dates = d.map { |a| Date.commercial(a["year"].to_i,a["week"].to_i,1) if !a['year'].nil? && !a['week'].nil? }
		if y.count > 0
			if dates.last >= Date.today.beginning_of_week-1
				dates.pop
				y.pop	
			end
		end
		if !dates.blank?
			data["dates"]=((dates.first..(Date.today.beginning_of_week-7)).step(7)).to_a
			data["y"]=Array.new(data["dates"].length,0)
			dates.each_with_index do |d,i|
				data["y"][data["dates"].index(d)]=y[i]
			end
		end
		return data
	end
  
  def get_orders(location,leadTime)
		before_date=Date.today + leadTime
		# Orders from Suppliers
		oco = 0
		self.get_current_shipments(location).each do |co|
			pc=co.product_counts.find_by_sku_id(self)
			if co.expected_date < before_date
					oco = oco + pc.count
			end
		end
		return oco
	end
  
  def get_current_shipments(location)
		self.events.where(event_type: location, received: false)
	end
  
  def forcast_demand(location)
		inv=inventory(location)
		start=Date.today
		max_lead_time=130.0;
		y=self.get_trend["y"]
		dates=self.get_trend["dates"]
		x=Array.new
		levels=[inv]
		if y.count > 2
			dates.each_with_index do |d,i|
				x[i]=(d-dates[0]).to_i
			end
			lineFit = LineFit.new
			lineFit.setData(x,y)
			b, m = lineFit.coefficients
			curdate = Date.today
			n = x.last + 1
			while curdate < start+max_lead_time
				levels << levels.last
				levels[-1] -= (m*n+b)/7
				events.where(event_type: location, received: false).each do |po|
					if po.expected_date == curdate
						cnt=po.product_counts.where(sku_id: id).first
						levels[-1] += cnt.count
					end
				end
				curdate += 1
				n += 1
			end
		end
		if levels
			return levels
		else
			return Array.new(2){0}
		end
	end
  
  def fees
  	size_tier=get_product_size_tier
		if size_tier.include?("Standard")
			order_handling = 1
			pick_and_pack = 1.02
			special_handling=0
			if size_tier.include?("Small")
				weight_handling = 0.46
			elsif size_tier.include?("Large")
				if weight <= 1
					weight_handling = 0.55
				elsif weight <= 2
					weight_handling = 1.34
				else
					weight_handling = 1.34 + (weight-2).ceil*0.39
				end
			end
		else
			order_handling = 0
			if size_tier.include?("Small")
				pick_and_pack = 4.03
				weight_handling = 1.34 + (weight-2).ceil*0.39
				special_handling=0
			elsif size_tier.include?("Medium")
				pick_and_pack = 5.07
				weight_handling = 1.91 + (weight-2).ceil*0.39
				special_handling=0
			elsif size_tier.include?("Large")
				pick_and_pack = 8.12
				weight_handling = 61.62 + (weight-90).ceil*0.80
				special_handling=0
			else
				pick_and_pack = 10.25
				weight_handling = 124.08 + (weight-90).ceil*0.92
				special_handling=40
			end
		end
		if Date.today.month < 10
			inventory_fee = 0.48*(height*length*width)/(12**3)
		else
			inventory_fee = 0.64*(height*length*width)/(12**3)
		end
		
		return {order_handling: order_handling,pick_and_pack: pick_and_pack,weight_handling: weight_handling,special_handling: special_handling,inventory_fee: inventory_fee}
  end
  
  def get_product_size_tier
		weight_limit_small_standard = 12.0/16.0
	 	max_side_limit_small_standard = 15
	 	mean_side_limit_small_standard = 12
	 	min_side_limit_small_standard = 0.75
	 	
		weight_limit_large_standard = 20
	 	max_side_limit_large_standard = 18
	 	mean_side_limit_large_standard = 14
	 	min_side_limit_large_standard = 8

		weight_limit_small_oversize = 70
	 	max_side_limit_small_oversize = 60
	 	mean_side_limit_small_oversize = 30
	 	min_side_limit_small_oversize = nil
	 	length_girth_limit_small_oversize = 130
	 	
	 	weight_limit_medium_oversize = 150
	 	max_side_limit_medium_oversize = 108
	 	mean_side_limit_medium_oversize = nil
	 	min_side_limit_medium_oversize = nil
	 	length_girth_limit_medium_oversize = 130
	 	
	 	weight_limit_large_oversize = 150
	 	max_side_limit_large_oversize = 108
	 	mean_side_limit_large_oversize = nil
	 	min_side_limit_large_oversize = nil
	 	length_girth_limit_large_oversize = 165
	 	
		dimensions = [length,height,width].sort
		girth = 2*(dimensions[1] + dimensions[0])
		if weight < weight_limit_small_standard && dimensions[0] < min_side_limit_small_standard && dimensions[1] < mean_side_limit_small_standard && dimensions[2] < max_side_limit_small_standard
			size_tier = "Small Standard"
		elsif weight < weight_limit_large_standard && dimensions[0] < min_side_limit_large_standard && dimensions[1] < mean_side_limit_large_standard && dimensions[2] < max_side_limit_large_standard
			size_tier = "Large Standard"
		elsif weight < weight_limit_small_oversize && dimensions[1] < mean_side_limit_small_oversize && dimensions[2] < max_side_limit_small_oversize && dimensions[2]+girth < length_girth_limit_small_oversize
			size_tier = "Small Oversize"
		elsif weight < weight_limit_medium_oversize && dimensions[2] < max_side_limit_medium_oversize && dimensions[2]+girth < length_girth_limit_medium_oversize
			size_tier = "Medium Oversize"
		elsif weight < weight_limit_large_oversize && dimensions[2] < max_side_limit_large_oversize && dimensions[2]+girth < length_girth_limit_large_oversize
			size_tier = "Large Oversize"
		else
			size_tier = "Missing or Special"
		end
  end
  
  def self.inventory_client(location)
  	data=amazon_id(location)
  	return MWS.fulfillment_inventory(data)
  end
  
  def self.report(location)
  	data=amazon_id(location)
  	return MWS.fulfillment_inventory(data)
  end
  
  def amazon_sales_count(origin)
  	sql = ActiveRecord::Base.connection()
  	d=sql.execute("SELECT SUM(orders.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id WHERE (offerings.sku_id = '#{id}') AND (orders.origin = '#{origin}') GROUP BY year, week ORDER BY year, week ")
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
  
  def inventory(location)
  	ic=Sku.inventory_client(location)
    resp = ic.list_inventory_supply seller_skus: [name]
    items = resp.xml['ListInventorySupplyResponse']['ListInventorySupplyResult']['InventorySupplyList']['member']
   	items['TotalSupplyQuantity'].to_i
  end
  
  def self.amazon(location)
  	skus=all.map(&:name).uniq.reject { |c| c.blank? }
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
  
   def amazon_need(currentInventory,origin,leadTime)
		y = self.amazon_sales_count(origin)["y"]
		pipeLine = self.get_orders(origin,leadTime)
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
		needed = averageNetInventory+predictedDemand2 - (currentInventory+ pipeLine)
		return needed
	end
 
  
  def self.search(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(all) do |combined_scope, word|
					combined_scope.where('LOWER(name) LIKE ?',"%#{word.downcase}%")
		  end
  	else
  		return all
  	end
  end
end
