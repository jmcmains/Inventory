class Product < ActiveRecord::Base
	has_many :offering_products
	has_many :product_counts, :dependent => :destroy
	has_many :events, through: :product_counts
	has_many :offerings, through: :offering_products
	
	def get_last(event_name)
		self.events.find_all_by_event_type(event_name).sort_by(&:date).last
	end
	
	def cogs(start_date,end_date)
	 	output={}
	 	sql = connection()
	 	if Rails.env.production?
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity) as purchases FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{id}) AND orders.date <= '#{end_date}'::date AND orders.date >= '#{start_date}'::date")
			purchases=d[0]["purchases"].to_i
			d=sql.execute("SELECT product_counts.count as count, product_counts.is_box as box, events.id as id, product_counts.price as price from product_counts INNER JOIN events ON events.id = product_counts.event_id WHERE (product_counts.product_id = #{id}) AND events.received AND events.received_date <= '#{end_date}'::date ORDER BY events.received_date")
			inv=d.map { |a| a["count"].to_i }.reverse
			box=d.map { |a| a["box"]=="t" }.reverse
			price = d.map { |a| a["price"].to_f }.reverse
			event_id = d.map { |a| a["id"].to_i }.reverse
			inv.each_with_index do |c,i| 
				if box[i]
					inv[i] = per_box * c
				end
				price[i] = price[i]/inv[i] + Event.find(event_id[i]).per_unit_cost
			end
			i=0
			total = purchases
			value = 0;
			if inv.sum > total
				while total > 0
					if total >= inv[i]
						total = total-inv[i]
						value = value + inv[i]*price[i]
					elsif total < inv[i]
						value = value + total*price[i]
						total = 0
					end
					i=i+1
				end
			else
				if inv.sum > 0
					val = 0
					inv.each_with_index do |c,i|
						val = inv[i]*price[i] + val
					end
					value = (val/inv.sum) * purchases
				end
			end
			output["value"]=value
			output["purchases"]=purchases
		else
			output["value"]=rand*100
			output["purchases"]=rand*1000
		end
		return output
	end
	
	def inventory
		self.events.inventory
	end
	
	def next
    Product.where("id > ?", id).order("id ASC").first
  end

  def previous
    Product.where("id < ?", id).order("id DESC").first
  end
	
	def product_orders
		self.events.product_orders
	end
	
	def running_out?
		limit = 14 #Days
		return forcast_demand[0..(limit-1)].map { |d| d < 0 }.include?(true)
	end
	
	def image
		base = "http://rubberbanditz.com/wp-content/themes/rubberbanditzNew/proImg/"
		return base+im
	end
	
	def self.search(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(scoped) do |combined_scope, word|
		    combined_scope.where('LOWER(name) LIKE ?',"%#{word.downcase}%")
		  end
  	else
  		return find(:all)
  	end
  end
  
	def get_last_count(event_name)
		if e=get_last(event_name)
			e.product_counts.find_by_product_id(self)
		else
			return 0
		end
	end
	
	def get_current_shipments
		self.events.find_all_by_event_type_and_received("Product Order",false)
	end
	
	def get_cust_orders
		return Order.joins(:offering => {:offering_products => :product}).where(["products.id = ? AND offering_products.quantity > 0",self])
	end
	
	require 'csv'
	def self.get_combos
		sql = ActiveRecord::Base.connection()
		d=sql.execute("SELECT products.id AS product_id, orders.order_number AS order_number FROM products INNER JOIN offering_products ON offering_products.product_id = products.id INNER JOIN offerings ON offerings.id = offering_products.offering_id INNER JOIN orders ON orders.offering_id = offerings.id WHERE offering_products.quantity > 0 ORDER BY product_id")
		order_numbers=Order.uniq { |v| v.order_number }.map { |v| v.order_number}
		data=d.map { |a| [a["order_number"], a["product_id"]] }
		combos=[]
		order_numbers.each do |on|
			combos << data.find_all { |v| v[0] == on }.map { |v| v[1] }.join(",")
		end
		final_data=combos.uniq.map { |a| [a,combos.count { |b| b == a }] }
		csv1 = CSV.generate(col_sep: "\t") do |csv|
			csv << ["combo", "times purchased"]
			final_data.each do |fd|
				csv << [fd[0],fd[1]]
			end
		end
		send_data csv1, type: 'text/csv', filename: "Shipping_data_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
	end
	
	def get_trend
		sql = connection()
		data= {}
		data['y'] = []
		data['dates'] = []
		if Rails.env.production?
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{self.id}) GROUP BY year, week ORDER BY year, week ")
			data["y"]=d.map { |a| a["sum"].to_i }
			data["dates"] = d.map { |a| Date.commercial(a["year"].to_i,a["week"].to_i,1) if !a['year'].nil? && !a['week'].nil? }
		else
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), strftime('%Y-%W', orders.date) AS year, orders.date AS bow FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{self.id}) GROUP BY year") 
			i=0
			d.each do |a|
				if a[2]
					data["y"][i] = a[0]
					data["dates"][i] = a[2].to_date.beginning_of_week
					i=i+1
				end
			end
		end
		if data["y"].count > 0
			if data["dates"].last >= Date.today.beginning_of_week-1
				data["dates"].pop
				data["y"].pop	
			end
		end
		return data
	end
	
	def self.get_trend
		sql = connection()
		data= {}
		data['y']=[]
		data['dates']=[]
		if Rails.env.production?
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id GROUP BY year, week ORDER BY year, week ")
			data["y"]=d.map { |a| a["sum"].to_i }
			data["dates"] = d.map { |a| Date.commercial(a["year"].to_i,a["week"].to_i,1) }
		else
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), strftime('%Y-%W', orders.date) AS year, orders.date AS bow FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id GROUP BY year") 
			i=0
			d.each do |a|
				if a[2]
					data["y"][i] = a[0]
					data["dates"][i] = a[2].to_date.beginning_of_week
					i=i+1
				end
			end
		end
		if data["dates"].last >= Date.today.beginning_of_week-1
			data["dates"].pop
			data["y"].pop	
		end
		return data
	end
	
	def forcast_demand
		start=Date.today.beginning_of_week
		inv=get_last_count("Inventory")
		if inv.instance_of?(ProductCount) && inv.count
			if inv.is_box
				inventory = inv.count*self.per_box
			else
				inventory = inv.count
			end
		else
			inventory=0
		end
		max_lead_time=130.0;
		y=self.get_trend["y"]
		dates=self.get_trend["dates"]
		x=Array.new
		levels=[inventory]
		if y.count > 2
			dates.each_with_index do |d,i|
				x[i]=(d-dates[0]).to_i
			end
			lineFit = LineFit.new
			lineFit.setData(x,y)
			b, m = lineFit.coefficients
			
			curdate = Date.today.beginning_of_week + 1
			if Date.today.beginning_of_week == inv.event.date.beginning_of_week
				n = x.last + 1
			else
				n = x.last + (Date.today.beginning_of_week-inv.event.date.beginning_of_week)
			end
			while curdate < start+max_lead_time
				levels << levels.last
				levels[-1] -= (m*n+b)/7
				events.unreceived.each do |po|
					if po.expected_date == curdate
						cnt=po.product_counts.find_by_product_id(self)
						if cnt.is_box
							levels[-1] += cnt.count*self.per_box
						else
							levels[-1] += cnt.count
						end
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
	
	def get_Inventory
		# Inventory
		last_inv=self.get_last_count("Inventory");
		if last_inv != 0
			if last_inv.is_box
				li = last_inv.count*(self.per_box? ? self.per_box : 0 )
			else
				li = last_inv.count
			end
		else
			li = 0
		end
		return li
	end

	def get_orders(leadTime)
		before_date=Date.today + leadTime
		# Orders from Suppliers
		oco = 0
		self.get_current_shipments.each do |co|
			pc=co.product_counts.find_by_product_id(self)
			if co.expected_date < before_date
				if pc.is_box
					oco = oco + (pc.count*(self.per_box? ? self.per_box : 0 ))
				else
					oco = oco + pc.count
				end
			end
		end
		return oco
	end
	
	def need(leadTime)
		currentInventory = self.get_Inventory
		pipeLine = self.get_orders(leadTime)
		# Customer Orders
		y=self.get_trend["y"]
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
		needed = averageNetInventory+predictedDemand2 - (currentInventory + pipeLine)
		return needed
	end
	
	def product_name
  	try(:name)
  end
  
  def product_name=(name)
  	Product.find_or_create_by_name(name) if name.present?
  end
end
