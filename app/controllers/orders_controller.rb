class OrdersController < ApplicationController
  def new
		@title ="Upload Order Files"
  end
  
  def create_single
  	@order = Order.new(params[:order])
		@order.save
		flash[:success] = "Single Order Loaded"
    redirect_to new_order_path
  end
  
require 'csv'
require 'net/ftp'
def create
	infile = params[:order][:file].read
	CSV.parse(infile, headers: true, quote_char: '"', col_sep: "\t") do |row|
		order = Order.shipworks_csv(row)
		if order.valid?
			order.save
		end
	end
	flash[:success] = "Orders Loaded"
	redirect_to new_order_path
end

def create1
	if params[:order][:origin] == "Amazon US" || params[:order][:origin] == "Amazon Canada" || params[:order][:origin] == "Website" || params[:order][:origin] == "Buy" || params[:order][:origin] == "EBay" || params[:order][:origin] == "Shipworks"
		infile = params[:order][:file].read
		order2=[]
		if params[:order][:origin] == "Amazon US" || params[:order][:origin] == "Amazon Canada" || params[:order][:origin] == "Buy"
			CSV.parse(infile, headers: true, col_sep: "\t") do |row|
				order = Order.build_from_csv(row,params[:order][:origin])
				if order.valid?
					order2 = order2 << order
				end
			end
		elsif params[:order][:origin] == "EBay"
			csv = CSV.parse(infile, headers: false, col_sep: ",", quote_char: '"')
			len=csv.length
			csv.each_with_index do |row,i|
				if i>2 && i<(len-3)
					if row[33].blank?
						order = Order.build_from_csv(row,params[:order][:origin])
						order2 = order2 << order
					else
						if !row[12].blank?
							order_number = row[33]
							date = Date.strptime(row[22],"%b-%d-%Y")+2000.years
							offering_id = row[12]
							quantity = row[14]
							offering=Offering.find_or_initialize_by_name(offering_id)
    					offering.save
    					order= Order.create(order_number: order_number, date: date,offering_id: offering.id,quantity: quantity, origin: params[:order][:origin])
    					order2 = order2 << order
						end
					end
						
				end
			end
		elsif params[:order][:origin] == "Website"
			CSV.parse(infile, headers: true, quote_char: '"') do |row|
				order = Order.build_from_csv(row,params[:order][:origin])
				if order.valid?
					order2 = order2 << order
				end
			end
		elsif params[:order][:origin] == "Shipworks"
			CSV.parse(infile, headers: true, quote_char: '"', col_sep: "\t") do |row|
				order = Order.shipworks_csv(row)
				if order.valid?
					order2 = order2 << order
				end
			end
		end
		order2.each do |o|
			o.save
		end
		flash[:success] = "Orders Loaded"
		redirect_to new_order_path
	elsif params[:order][:origin] == "Endicia"
		infile = params[:order][:file].read
		merchant_order_id=Array.new
		tracking_number=Array.new
		ship_date=Array.new
		i=0
		CSV.parse(infile) do |row|
			merchant_order_id[i] = row[13]
			tracking_number[i] = row[7]
			ship_date[i] = row[2]
			i=i+1
		end
		csv = CSV.generate(col_sep: "\t") do |csv|
			csv << ["merchant order id", "tracking number", "carrier code", "other carrier name", "ship date"]
			(2..(i-4)).to_a.each do |j|
				if !merchant_order_id[j].blank? && merchant_order_id[j].length == 17
					moi = merchant_order_id[j];
					date = Date.strptime(ship_date[j], "%m/%d/%y").strftime("%Y-%m-%d")
					tn = tracking_number[j][1..-2]
					csv << [moi, tn, "USPS", nil, date]
				end
			end
		end
		send_data csv, type: 'text/csv', filename: "Shipping_data_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
	end
end
  
	def index

	end

  def destroy
  end
end
