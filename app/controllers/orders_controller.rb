class OrdersController < ApplicationController
  def new
		@title ="Upload Order Files"
  end
  
require 'csv'
  def create
  
  	if params[:order][:type] == "Amazon US" || params[:order][:type] == "Amazon Canada" || params[:order][:type] == "Website"
			infile = params[:order][:file].read
			order2=[]
			if params[:order][:type] == "Amazon US" || params[:order][:type] == "Amazon Canada"
				CSV.parse(infile, headers: true, col_sep: "\t") do |row|
					order = Order.build_from_csv(row,params[:order][:type])
					if order.valid?
						order2 = order2 << order
					end
				end
			else
					CSV.parse(infile, headers: true, quote_char: '"') do |row|
					order = Order.build_from_csv(row,params[:order][:type])
					if order.valid?
						order2 = order2 << order
					end
				end
			end
			order2.each do |o|
				o.save
			end
		else
			@order = Order.new(params[:order])
		  @order.save
		  redirect_to root_path
		end
  end
	
	def new_phone
		@order = Order.new
	end
 
	def index
		@orders = Order.find(:all, :order => 'date, id')
		@order_months = @orders.group_by { |t| t.date.beginning_of_month }
	end

  def destroy
  end
end
