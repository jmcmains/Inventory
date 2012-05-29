class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :offering, :class_name => "Offering"
  
  def month
  	self.date.month
 	end
 	
 	def day
  	self.date.day
 	end
 	
 	def year
 		self.date.year
 	end
 	
 	def quant(pq)
 		return self.quantity * pq.find_by_offering_id(self.offering).quantity
 	end
 	def find_by_month(month,year)
 		Order.find(:all, :conditions => ["MONTH(order) = ? AND YEAR(order) = ?", month, year])
 	end
 	
 	def week
 		self.date.strftime("%W").to_i
 	end
 	
  def self.build_from_csv(row,type)
    # find existing customer from email or create new
    if type == "Amazon US"
		  order_number = row[0]
		  date = row[2]
			offering_id=row[10]
			quantity = row[14]
    elsif type == "Amazon Canada"
    	order_number = row[0]
    	date = row[2]
			offering_id=row[8]
			quantity = row[9]
    else
    	order_number = row[1]
    	if row[2].blank?
    		old_order=Order.find_by_order_number(order_number)
    		date = old_order.date
    	else
    		date = row[2]
    	end
			offering_id=row[31]
			quantity = row[32]
    end
    offering=Offering.find_or_initialize_by_name(offering_id)
    offering.save
    order= Order.create(order_number: order_number, date: date,offering_id: offering.id,quantity: quantity)
    return order
  end
end
