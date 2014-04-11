# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

puts "Importing offerings..."
CSV.foreach(Rails.root.join('db/offerings.csv'), headers: true, col_sep: "\t") do |row|
  Offering.create! do |p|
    p.name = row[0]
  end
end

puts "Importing products..."
CSV.foreach(Rails.root.join('db/products.csv'), headers: true) do |row|
  Product.create! do |p|
    p.name = row[0]
    p.description = row[1]
    p.per_box = row[2]
    p.imloc = row[3]
  end
end

puts "Importing offering products..."
CSV.foreach(Rails.root.join('db/offering_products.csv'), headers: true) do |row|
  OfferingProduct.create! do |p|
    p.offering_id = row[0]
    p.product_id = row[1]
    p.quantity = row[2]
  end
end

puts "Importing events..."
CSV.foreach(Rails.root.join('db/events.csv'), headers: true) do |row|
  Event.create! do |p|
    p.date = row[0]
    p.event_type = row[1]
    p.invoice = row[2]
    p.received_date = row[3]
    p.received = row[4]
  end
end

puts "Importing product counts..."
CSV.foreach(Rails.root.join('db/product_counts.csv'), headers: true) do |row|
  ProductCount.create! do |p|
    p.event_id = row[0]
    p.product_id = row[1]
    p.count = row[2]
    p.is_box = row[3]
  end
end

puts "Importing amazon 5/26/2012..."
CSV.foreach(Rails.root.join('db/2012-05-26.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 6/2011..."
CSV.foreach(Rails.root.join('db/2011-06.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 7/2011..."
CSV.foreach(Rails.root.join('db/2011-07.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 8/2011..."
CSV.foreach(Rails.root.join('db/2011-08.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 9/2011..."
CSV.foreach(Rails.root.join('db/2011-09.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 10/2011..."
CSV.foreach(Rails.root.join('db/2011-10.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 11/2011..."
CSV.foreach(Rails.root.join('db/2011-11.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 12/2011..."
CSV.foreach(Rails.root.join('db/2011-12.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 1/2012..."
CSV.foreach(Rails.root.join('db/2012-01.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 2/2012..."
CSV.foreach(Rails.root.join('db/2012-02.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 3/2012..."
CSV.foreach(Rails.root.join('db/2012-03.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end

puts "Importing amazon 4/2012..."
CSV.foreach(Rails.root.join('db/2012-04.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[14]
   	p.offering_id = Offering.find_or_initialize_by_name(row[10]).id
   	   	p.origin = "Amazon US"
  end
end


puts "Importing amazon canada 4/2012..."
CSV.foreach(Rails.root.join('db/2012-04-canada.txt'), headers: true, col_sep: "\t") do |row|
  Order.create! do |p|
    p.order_number = row[0]
    p.date = row[2]
   	p.quantity = row[9]
   	p.offering_id = Offering.find_or_initialize_by_name(row[8]).id
   	   	p.origin = "Amazon Canada"
  end
end

puts "Importing website until 5/26/2012..."
CSV.foreach(Rails.root.join('db/Cart66Report.csv'), headers: true) do |row|
  Order.create! do |p|
    p.order_number = row[1]
    if row[2].blank?
  		old_order=Order.find_by_order_number(p.order_number)
  		p.date = old_order.date
  	else
  		p.date = row[2]
  	end
   	p.quantity = row[32]
   	p.offering_id = Offering.find_or_initialize_by_name(row[31]).id
   	   	p.origin = "Website"
  end
end

