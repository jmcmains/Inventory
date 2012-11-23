class CustomersController < ApplicationController
  def new
  	@customer = Customer.new
  	@customer.orders.build
  	@title = "New Phone/Email Order"
  end
  
	def create
		@customer = Customer.new(params[:customer])
		@customer.save
		@customer.orders.each do |o|
			o.update_attributes(date: convert_date(params[:date]),order_number: @customer.transaction_number, origin: "phone or email")
		end
    redirect_to @customer
  end
  
  def send_email
  	@customer = Customer.find(params[:id])
  	CustomerMailer.oe_email(@customer).deliver
  	CustomerMailer.customer_email(@customer).deliver
  	flash[:success] = "Email sent!"
  	redirect_to @customer
  end
  
  def send_oe_email
  	@customer = Customer.find(params[:id])
  	CustomerMailer.oe_email(@customer).deliver
  	flash[:success] = "OE Email sent!"
  	redirect_to @customer
  end
  
  def send_customer_email
  	@customer = Customer.find(params[:id])
  	CustomerMailer.customer_email(@customer).deliver
  	flash[:success] = "Customer Email sent!"
  	redirect_to @customer
  end
  
  def index
		@customers = Customer.search(params[:search]).paginate(:page => params[:page], :per_page => 10)
  	@title = "All Phone/Email Orders"
  end
  
  def show
  	@customer = Customer.find(params[:id])
  	@title = "#{@customer.first_name} #{@customer.last_name}"
  end
  
  def edit
  	@customer = Customer.find(params[:id])
  	@title = "Edit Phone/Email Order"
  end
  
	def update
  	@customer = Customer.find(params[:id])
    @customer.update_attributes(params[:customer])
    @customer.orders.each do |o|
			o.update_attributes(date: convert_date(params[:date]),order_number: @customer.transaction_number, origin: "phone or email")
		end
  	redirect_to @customer
  end
  
  def destroy
		Customer.find(params[:id]).destroy
	  redirect_to customers_path
  end
	private
	 
		def convert_date(hash)
		  return Date.new(hash['year'].to_i, hash['month'].to_i, hash['day'].to_i)   
		end
end
