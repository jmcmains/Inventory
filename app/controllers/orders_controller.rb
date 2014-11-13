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
	
	def destroy_range
	  start_date = Date.new(params[:start_date]["day(1i)"].to_i,params[:start_date]["day(2i)"].to_i,params[:start_date]["day(3i)"].to_i)
	  end_date = Date.new(params[:end_date]["day(1i)"].to_i,params[:end_date]["day(2i)"].to_i,params[:end_date]["day(3i)"].to_i)
    Order.where('date >= ? AND date <= ?',start_date,end_date).destroy_all
    flash[:success] = "Orders Deleted"
    redirect_to new_order_path
	end
	
	def load_data
		@data=params
	end
	
	def create
		infile = params[:order][:file].read
		#CSV.parse(infile, headers: true, quote_char: '"', col_sep: "\t") do |row|
		#	Order.shipworks_csv(row)
		#end
		#flash[:success] = "Orders Loaded"
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
