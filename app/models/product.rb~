class Product < ActiveRecord::Base
	has_many :offering_products
	has_many :product_counts, :dependent => :destroy
	has_many :events, through: :product_counts
	has_many :offerings, through: :offering_products
	
	def get_last(event_name)
		self.events.find_all_by_event_type(event_name).sort_by(&:date).last
	end
	
	def inventory
		self.events.inventory
	end
	
	def next
		id < Product.last.id ? Product.find(id+1) : nil
	end
	
	def previous
		id > 1 ? Product.find(id-1) : nil
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
	
	def get_trend
		sql = connection()
		data= {}
		if Rails.env.production?
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{self.id}) GROUP BY year, week ORDER BY year, week ")
			data["y"]=d.map { |a| a["sum"].to_i }
			data["dates"] = d.map { |a| Date.commercial(a["year"].to_i,a["week"].to_i,1) if !a['year'].nil? && !a['week'].nil? }
		else
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), strftime('%Y-%W', orders.date) AS year, orders.date AS bow FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{self.id}) GROUP BY year") 
			data["y"]=d.map { |a| a[0] }
			data["dates"]=d.map{ |a| a[2].to_date.beginning_of_week }
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
		if Rails.env.production?
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id GROUP BY year, week ORDER BY year, week ")
			data["y"]=d.map { |a| a["sum"].to_i }
			data["dates"] = d.map { |a| Date.commercial(a["year"].to_i,a["week"].to_i,1) }
		else
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), strftime('%Y-%W', orders.date) AS year, orders.date AS bow FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id GROUP BY year") 
			data["y"]=d.map { |a| a[0] }
			data["dates"]=d.map{ |a| a[2].to_date.beginning_of_week }
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
		if inv.is_box
			inventory = inv.count*self.per_box
		else
			inventory = inv.count
		end
		max_lead_time=130.0;
		y=self.get_trend["y"]
		dates=self.get_trend["dates"]
		x =Array.new
		dates.each_with_index do |d,i|
			x[i]=(d-dates[0]).to_i
		end
		lineFit = LineFit.new
		lineFit.setData(x,y)
		b, m = lineFit.coefficients
		levels=[inventory]
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
		return levels
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
