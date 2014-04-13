class OrdersController < ApplicationController
	require 'csv'
	require 'net/ftp'
	def new
		@title ="Upload Order Files"
	end

	def create_single
		@order = Order.new(order_params)
		@order.save
		flash[:success] = "Single Order Loaded"
		redirect_to new_order_path
	end
	
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

	def orphans
		@title="Orphaned Orders"
		@orphans=Order.where(["offering_id NOT IN (?)",Offering.pluck("id")]).sort_by(&:order_number)
	end

	def replace
		session[:return_to] ||= request.referer
		order = Order.find(params[:id])
		offering_id=order.offering_id
		replace=Offering.where(name: params[:offering_name]).first_or_create
		replace.save!
		Order.where(offering_id: offering_id).update_all({:offering_id => replace.id})
		@orphans=Order.where(["offering_id NOT IN (?)",Offering.pluck("id")]).sort_by(&:order_number)
	  redirect_to session.delete(:return_to)
	end

	def destroy
		session[:return_to] ||= request.referer
		Order.find(params[:id]).destroy
	  redirect_to session.delete(:return_to)
	end
private


def order_params
params.require(:order).permit(:order_number,:date,:offering_id,:quantity,:origin,:customer_id,:offering_name)
end

end
