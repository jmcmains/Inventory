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
		a =[]
		self.offerings.each do |o|
			a= a + o.orders
		end
		return a
	end
	
	def need
		# Inventory
		last_inv=self.get_last_count("Inventory");
		if last_inv.is_box
			li = last_inv.count*self.per_box
		else
			li = last_inv.count
		end
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
		# Customer Orders
		o=self.get_cust_orders.group_by { |t| t.date.beginning_of_week }
		y = []
		o.sort.each do |week, orders|
			c=0
			for order in orders
				c=c+(order.quantity * order.offering.offering_products.find_by_product_id(self).quantity)
			end
			y = y << c
		end
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
