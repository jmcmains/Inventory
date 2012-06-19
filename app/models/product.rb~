class Product < ActiveRecord::Base
	has_many :offering_products
	has_many :product_counts, :dependent => :destroy
	has_many :events, through: :product_counts
	has_many :offerings, through: :offering_products
	
	def get_last(event_name)
		self.events.find_all_by_event_type(event_name).last
	end
	
	def image
		base = "http://rubberbanditz.com/wp-content/themes/rubberbanditzNew/proImg/"

		return base+im
	end
	
	def get_last_count(event_name)
		e=get_last(event_name)
		e.product_counts.find_by_product_id(self)
	end
	
	def get_current_shipments
		self.events.find_all_by_event_type_and_received("Product Order",false)
	end
	
	def get_cust_orders
		return Order.joins(:offering => {:offering_products => :product}).where(["products.id = ? AND offering_products.quantity > 0",self])
	end
	
	def get_trend
		sql = ActiveRecord::Base.connection()
		if Rails.env == "production"
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), EXTRACT(ISOYEAR FROM orders.date) AS year, EXTRACT(WEEK FROM orders.date) AS week FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{self.id}) GROUP BY year, week ORDER BY year, week ")
			y=d.map { |a| a["sum"].to_i }
		else
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), strftime('%Y-%W', orders.date) AS year FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{self.id}) GROUP BY year")
			y=d.map { |a| a[0] }
		end
		return y
	end
	
	def get_Inventory
		# Inventory
		last_inv=self.get_last_count("Inventory");
		if last_inv.is_box
			li = last_inv.count*self.per_box
		else
			li = last_inv.count
		end
		return li
	end

	def get_orders
		# Orders from Suppliers
		oco = 0
		self.get_current_shipments.each do |co|
			pc=co.product_counts.find_by_product_id(self)
			if pc.is_box
				oco = oco + (pc.count*self.per_box)
			else
				oco = oco + pc.count
			end
		end
		return oco
	end
	
	def need(leadTime)
		currentInventory = self.get_Inventory
		pipeLine = self.get_orders
		# Customer Orders
		y=self.get_trend
		x =(1..y.length).to_a
		lineFit = LineFit.new
		lineFit.setData(x,y)
		b, m = lineFit.coefficients
		sigma = lineFit.sigma
		leadTimeWeeks = (leadTime/7).ceil
		averageNetInventory = 2*sigma*Math.sqrt(leadTimeWeeks)
		weeks = (0..leadTimeWeeks).map { |w| w+y.length }
		predictedDemand = weeks.map { |x1| m*x1+b }
		predictedDemand2= predictedDemand.sum - predictedDemand[0]
		needed = averageNetInventory+predictedDemand2 - (currentInventory + pipeLine)
		return needed
	end

end
