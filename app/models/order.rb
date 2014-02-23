class Order < ActiveRecord::Base
require 'csv'
	require 'net/ftp'
	require 'open-uri'
  belongs_to :offering, :class_name => "Offering"
  has_many :offering_products, through: :offering
  has_many :products, through: :offering_products
  belongs_to :customer
  default_scope { order('orders.date DESC') }
  scope :amzus, -> { where(origin: "Amazon US") }
  scope :amzca, -> { where(origin: "Amazon Canada") }
  scope :website, -> { where(origin: "Website") }
  scope :buy, -> { where(origin: "Buy") }
  scope :phone, -> { where(origin: "phone or email") }
  scope :ebay, -> { where(origin: "EBay") }
    
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
 	
 	def self.shipworks_csv(row)
		offering=Offering.find_or_initialize_by(name: row[4])
		price=row[5].to_f
		if (offering.price.blank? || offering.price < price) && (!price.blank?)
			offering.update_attributes(price: price)
		else
    	offering.save
    end
    return Order.create(order_number: row[0], date: Date.strptime(row[2], '%m/%d/%Y'),offering_id: offering.id,quantity: row[3], origin: row[1])

 	end
 	
 	def self.load_from_feed
 	  last_date=Order.all.sort_by(&:date).last.date
		CSV.parse(open('http://rubberbanditz.com/DailyOrders.txt'), headers: true, quote_char: '"', col_sep: "\t") do |row|
			order = Order.shipworks_csv(row)
			if order.date < last_date
			  break
			end
			if order.valid?
				order.save
			end
		end
 	end
  
  def offering_name
  	offering.try(:name)
  end
  
  def offering_name=(name)
  	self.offering = Offering.find_or_create_by(name: name) if name.present?
  end
end
