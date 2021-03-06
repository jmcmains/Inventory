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
			{merchant_id: ENV["amazon_us_merchant_id"],marketplace_id: ENV["amazon_us_marketplace_id"], aws_access_key_id: ENV["amazon_us_aws_access_key_id"], aws_secret_access_key: ENV["amazon_us_aws_secret_access_key"]}
		elsif location == "Amazon Canada"
			{merchant_id: ENV["amazon_ca_merchant_id"],marketplace_id: ENV["amazon_ca_marketplace_id"], aws_access_key_id: ENV["amazon_ca_aws_access_key_id"], aws_secret_access_key: ENV["amazon_ca_aws_secret_access_key"]}
		end
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
		y=self.amazon_sales_count(location)["y"]
		dates=self.amazon_sales_count(location)["dates"]
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
  
  def fees(origin)
    size_tier=get_product_size_tier(origin)
  	if origin == "Amazon Canada"
  		order_handling = 0
  		dimensional_weight=((length*width*height).to_unit("in^3").convert_to("cm^3")/6000).scalar.to_f.to_unit('g')
    	usable_weight=[dimensional_weight,weight.to_unit("lbs").convert_to("g")].max
			if size_tier == "Envelope"
				pick_and_pack = 1.55
				outbound_shipping_weight=((usable_weight + Unit('25 g'))/100.0).ceil*100.0
				weight_handling = 1.90 + (outbound_shipping_weight-Unit('100 g')).scalar.to_f*0.25
				special_handling=0
			elsif size_tier == "Parcel"
				pick_and_pack = 1.55
				outbound_shipping_weight=((usable_weight + Unit('25 g'))/500.0).ceil*500.0
				weight_handling = 3.75 + (outbound_shipping_weight-Unit('500 g')).scalar.to_f*0.37
				special_handling=0
			else
				pick_and_pack = 2.65
				outbound_shipping_weight=((usable_weight + Unit('25 g'))/500.0).ceil*500.0
				weight_handling = 3.75 + (outbound_shipping_weight-Unit('500 g')).scalar.to_f*0.37
				special_handling=125
			end
			volume=(length*width*height).to_unit("in^3").convert_to("m^3").scalar.to_f
			if Date.today.month < 10
				inventory_fee = 16*volume
			else
				inventory_fee = 23*volume
			end
  	else
			if size_tier.include?("Standard")
			 	outbound_shipping_weight=(weight + 4.0/16.0).ceil.to_f
				order_handling = 1
				pick_and_pack = 1.02
				special_handling=0
				if size_tier.include?("Small")
					weight_handling = 0.46
				elsif size_tier.include?("Large")
					if outbound_shipping_weight <= 1
						weight_handling = 0.55
					elsif outbound_shipping_weight <= 2
						weight_handling = 1.34
					else
						weight_handling = 1.34 + (outbound_shipping_weight-2.0).ceil*0.39
					end
				end
			else
				outbound_shipping_weight=([weight,(length*width*height)/166.0].max+16.0).ceil.to_f
				order_handling = 0
				if size_tier.include?("Small")
					pick_and_pack = 4.03
					weight_handling = 1.34 + (outbound_shipping_weight-2).ceil*0.39
					special_handling=0
				elsif size_tier.include?("Medium")
					pick_and_pack = 5.07
					weight_handling = 1.91 + (outbound_shipping_weight-2).ceil*0.39
					special_handling=0
				elsif size_tier.include?("Large")
					pick_and_pack = 8.12
					weight_handling = 61.62 + (outbound_shipping_weight-90).ceil*0.80
					special_handling=0
				else
					pick_and_pack = 10.25
					outbound_shipping_weight=(weight+16.0).ceil.to_f
					weight_handling = 124.08 + (outbound_shipping_weight-90).ceil*0.92
					special_handling=40
				end
			end
			if Date.today.month < 10
				inventory_fee = 0.48*(height*length*width)/(12**3)
			else
				inventory_fee = 0.64*(height*length*width)/(12**3)
			end
			
		end
		#shipping fee
		costs=Array.new
		amounts=Array.new
		events.where(event_type: origin, received: true).each do |event|
			shipment_weight=event.product_counts.map { |a| a.sku.weight*a.count }.sum
			costs << weight/shipment_weight*event.additional_cost
			amounts << event.product_counts.where(sku_id: id).first.count
		end
		if costs.count > 0
			shipping_cost=(0...costs.count).inject(0) {|r, i| r + costs[i]*amounts[i]}/amounts.sum
		else
			shipping_cost=0
		end
		#amazon finders fee
		current_price=offerings.first.blank? ? 0 : offerings.first.price
		referral_fee = [0.15*current_price,1].max
			
		amazon_cost=order_handling+pick_and_pack+weight_handling+special_handling+referral_fee
		total_cost= amazon_cost+inventory_fee+shipping_cost+cogs
		return {order_handling: order_handling,pick_and_pack: pick_and_pack,weight_handling: weight_handling,special_handling: special_handling,inventory_fee: inventory_fee,shipping_cost: shipping_cost,referral_fee: referral_fee,amazon_cost: amazon_cost, product_cost: cogs,total_cost: total_cost}
  end
  
  def asin(origin)
  	p=Sku.products_client(origin)
  	return p.get_my_price_for_sku(name).xml["GetMyPriceForSKUResponse"]["GetMyPriceForSKUResult"]["Product"]["Identifiers"]["MarketplaceASIN"]["ASIN"]
  end
  
  def get_product_size_tier(origin)
  	dimensions = [length,height,width].sort
		girth = 2*(dimensions[1] + dimensions[0])
  	if origin == "Amazon Canada"
  		weight_limit_envelope = Unit("500 g").convert_to('lbs').scalar.to_f
		 	max_side_limit_envelope = Unit("38 cm").convert_to('in').scalar.to_f
		 	mean_side_limit_envelope = Unit("27 cm").convert_to('in').scalar.to_f
		 	min_side_limit_envelope = Unit("2 cm").convert_to('in').scalar.to_f

  		weight_limit_parcel = Unit("9 kg").convert_to('lbs').scalar.to_f
		 	max_side_limit_parcel = Unit("45 cm").convert_to('in').scalar.to_f
		 	mean_side_limit_parcel = Unit("35 cm").convert_to('in').scalar.to_f
		 	min_side_limit_parcel = Unit("20 cm").convert_to('in').scalar.to_f
		 	
		 	if weight < weight_limit_envelope && dimensions[0] < min_side_limit_envelope && dimensions[1] < mean_side_limit_envelope && dimensions[2] < max_side_limit_envelope
				size_tier = "Envelope"
			elsif weight < weight_limit_parcel && dimensions[0] < min_side_limit_parcel && dimensions[1] < mean_side_limit_parcel && dimensions[2] < max_side_limit_parcel
				size_tier = "Parcel"
			else
				size_tier = "Oversize"
			end
  	else
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
  end
  
  def self.inventory_client(location)
  	data=amazon_id(location)
  	return MWS.fulfillment_inventory(data)
  end
  
  def self.products_client(location)
  	data=amazon_id(location)
  	return MWS.products(data)
  end
  
	def next_sku(origin)
		data=Sku.alphabetized(origin)
		loc=data.find_index(name)
		return Sku.where(name: (loc < data.length-1 ? data[loc+1] : data[0])).first
	end
	
	def prev_sku(origin)
		data=Sku.alphabetized(origin)
		loc=data.find_index(name)
		return Sku.where(name: (loc > 0 ? data[loc-1] : data[data.length-1])).first
	end
	
	def self.alphabetized(location)
		skus=all.map(&:name).uniq.reject { |c| c.blank? }
		offer = Array.new()
		ic=inventory_client(location)
		count=(skus.length/50.0).ceil
		(1..count).to_a.each do |i|
			resp = ic.list_inventory_supply seller_skus: skus[((i-1)*50)..[((i*50)-1),skus.length].min]
			items = resp.xml['ListInventorySupplyResponse']['ListInventorySupplyResult']['InventorySupplyList']['member']
			items=items.reject { |a| a["ASIN"].blank? }
			offer.concat(items.map{ |a| a["SellerSKU"] })
		end
		return offer.sort!
  end
  
  def self.inventory(skus,location)
  	ic=inventory_client(location)
    items = ic.list_inventory_supply(seller_skus: skus).xml['ListInventorySupplyResponse']['ListInventorySupplyResult']['InventorySupplyList']['member']
    if items.class == Array
    	items=items.reject { |a| a["ASIN"].blank? }
    	if items.length == 1
    		{items[0]['SellerSKU'] => items[0]['InStockSupplyQuantity'].to_i}
		  else
				items.inject Hash.new(0) do |inv,item|
				  	inv.merge(item['SellerSKU'] => item['InStockSupplyQuantity'].to_i)
				end
			end
    elsif items.class == Hash
    	{items['SellerSKU'] => items['InStockSupplyQuantity'].to_i}
    end
  end
  
  def inventory(location)
  	ic=Sku.inventory_client(location)
    resp = ic.list_inventory_supply seller_skus: [name]
    items = resp.xml['ListInventorySupplyResponse']['ListInventorySupplyResult']['InventorySupplyList']['member']
   	items['InStockSupplyQuantity'].to_i
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
