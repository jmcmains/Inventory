class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :offering, :class_name => "Offering"
  has_many :offering_products, through: :offering
  has_many :products, through: :offering_products
  belongs_to :customer
  default_scope order: 'orders.date DESC'
  scope :amzus, where(origin: "Amazon US")
  scope :amzca, where(origin: "Amazon Canada")
  scope :website, where(origin: "Website")
  scope :buy, where(origin: "Buy")
  scope :phone, where(origin: "phone or email")
  def month
  	self.date.month
 	end
 	def self.total_on(pdate)
 		where("date(date) = ?",pdate).sum(:quantity)
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
		elsif type == "Buy"
			order_number = row[3]
    	date = Date.strptime(row[1], '%m/%d/%Y')
			offering_id=row[7]
			quantity = row[9]
    elsif type == "Website"
    	order_number = row[1]
    	if row[2].blank?
    		old_order=Order.find_by_order_number(order_number)
    		date = old_order.date
    	else
    		date = row[2]
    	end
			offering_id=row[31]
			quantity = row[32]
		elsif type == "EBay"
			order_number = row[13]
			date = Date.strptime(row[25],"%b-%d-%Y")+2000.years
			offering_id = row[14]
			quantity = row[15]
    end
    offering=Offering.find_or_initialize_by_name(offering_id)
    offering.save
    order= Order.create(order_number: order_number, date: date,offering_id: offering.id,quantity: quantity, origin: type)
    return order
  end
  
  def offering_name
  	offering.try(:name)
  end
  
  def offering_name=(name)
  	self.offering = Offering.find_or_create_by_name(name) if name.present?
  end
end
