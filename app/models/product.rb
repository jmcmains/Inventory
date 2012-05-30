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
		d=sql.execute("SELECT sum('orders'.'quantity' *'offering_products'.'quantity') FROM 'orders' INNER JOIN 'offerings' ON 'offerings'.'id' = 'orders'.'offering_id' INNER JOIN 'offering_products' ON 'offering_products'.'offering_id' = 'offerings'.'id' INNER JOIN 'products' ON 'products'.'id' = 'offering_products'.'product_id' WHERE (products.id = #{self.id}) GROUP BY strftime('%Y-%W', 'orders'.'date')")
		y=d.map { |a| a[0] }
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
	
	def need
		li = self.get_Inventory
		oco = self.get_orders
		# Customer Orders
		y=self.get_trend
		x =(1..y.length).to_a
		lineFit = LineFit.new
		lineFit.setData(x,y)
		b, m = lineFit.coefficients
		omi = y[-4..-1].sum
		weeks = (1..10).map { |w| w+y.length }
		pu = weeks.map { |x| m*x+b }.sum
		needed = -li - oco + pu + omi
		return needed
	end

end
