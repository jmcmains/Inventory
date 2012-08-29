class OrdersController < ApplicationController
  def new
		@title ="Upload Order Files"
  end
  
require 'csv'
  def create
  	if params[:order][:origin] == "Amazon US" || params[:order][:origin] == "Amazon Canada" || params[:order][:origin] == "Website"
			infile = params[:order][:file].read
			order2=[]
			if params[:order][:origin] == "Amazon US" || params[:order][:origin] == "Amazon Canada"
				CSV.parse(infile, headers: true, col_sep: "\t") do |row|
					order = Order.build_from_csv(row,params[:order][:origin])
					if order.valid?
						order2 = order2 << order
					end
				end
			else
					CSV.parse(infile, headers: true, quote_char: '"') do |row|
					order = Order.build_from_csv(row,params[:order][:origin])
					if order.valid?
						order2 = order2 << order
					end
				end
			end
			order2.each do |o|
				o.save
			end
			flash[:success] = "Orders Loaded"
			redirect_to root_path
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
		@orders = Order.find(:all, :order => 'date, id')
		@order_months = @orders.group_by { |t| t.date.beginning_of_month }
	end

  def destroy
  end
end
