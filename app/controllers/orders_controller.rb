class OrdersController < ApplicationController
  def new
		@title ="Upload Order Files"
  end
  
require 'csv'
require 'net/ftp'
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
		elsif params[:order][:origin] == "Buy"
			end_date = Order.buy.count>0 ? Order.buy.sort_by(&:date).last.date : Date.new(0)
			ftp = Net::FTP.new('trade.marketplace.buy.com')
			ftp.login(user = "amz@rubberbanditz.com", passwd = "3ra9usW")
			files = ftp.chdir('/Orders')
			files = ftp.list('*.txt')
			(0..(files.count-1)).to_a.each do |i|
				ftp.getbinaryfile(files[i].split(' ').last, 'order.txt', 1024)
				CSV.foreach(Rails.root.join("order.txt"), headers: true, col_sep: "\t") do |row|
					if row[4] && Date.strptime(row[4].split(' ').first, "%m/%d/%Y") > end_date
						Order.create! do |p|
							p.order_number = row[1]
							p.date = Date.strptime(row[4].split(' ').first, "%m/%d/%Y")
							p.quantity = row[7]
							offering_id=row[10]
							offering=Offering.find_or_initialize_by_name(offering_id)
							p.offering_id=offering.id
							p.origin="Buy"
						end
					end
				end
			end
			ftp.close
			flash[:success] = "Orders Loaded"
			redirect_to root_path
		end
  end

	def index
		@orders = Order.find(:all, :order => 'date, id')
		@order_months = @orders.group_by { |t| t.date.beginning_of_month }
	end

  def destroy
  end
end
