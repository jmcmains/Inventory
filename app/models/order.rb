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
 		#"OrderID"	"StoreName"	"OrderDate"	"ItemQTY"	"ItemName"	"Price"	"SKU"	"FBA"
 		#<Order id: nil, order_number: nil, date: nil, offering_id: nil, quantity: nil, created_at: nil, updated_at: nil, origin: nil, customer_id: nil> 
 		#<Offering id: nil, name: nil, created_at: nil, updated_at: nil, price: nil, oldsku: nil, sku_id: nil> 
		#<Sku id: nil, name: nil, weight: nil, length: nil, width: nil, height: nil, created_at: nil, updated_at: nil> 

order_number = row[0]
origin=row[1]
order_date=row[2]
quantity=row[3]
offering_name=row[4]
price=row[5]
sku=row[6]
fba=row[7]
offering=Offering.where(name: offering_name).first_or_create do |offer|
offer.sku_id=Sku.where(name: sku).first_or_create.id
offer.price=price
existing= Offering.where(sku: offer.sku).first
if !existing.blank?
existing.offering_products.each do |op|
offer.offering_products.create(product_id: op.product_id, quantity: op.quantity)
end
end
end
date=order_date.blank? ? Date.new(2000,1,1) : Date.strptime(order_date, '%m/%d/%Y')
order = Order.where(order_number: order_number, offering_id: offering.id, origin: origin).first_or_create do |order1|
order1.fba=fba
order1.quantity= quantity
order1.date=date
end
 	end
 	
 	def self.load_from_feed
 	  last_date=Order.all.sort_by(&:date).last.date
		CSV.parse(open('http://rubberbanditz.com/MonthlyOrders.txt'), headers: true, quote_char: '"', col_sep: "\t") do |row|
			Order.shipworks_csv(row)
		end
 	end
  
  def offering_name
  	offering.try(:name)
  end
  
  def offering_name=(name)
  	self.offering = Offering.find_or_create_by(name: name) if name.present?
  end
end
