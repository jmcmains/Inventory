class OfferingsController < ApplicationController
  require 'will_paginate/array'
  require 'active_shipping'
	include ActiveMerchant::Shipping
  def new
  end

  def edit
  	@offering=Offering.find(params[:id])
  	@title = "Edit Offering"
  	@offering.offering_products.build
  end
  def destroy
		Offering.find(params[:id]).destroy
	  redirect_to offerings_path
  end
  
	def update
		@offering = Offering.find(params[:id])
	  @offering.update_attributes(offering_params)
	  @title = "Current Offerings and their products"
	  @offerings=Offering.includes(:products).where("products.id IS NULL").references(:products).paginate(:page => params[:page], :per_page => 10)
	  @blank = true
	  respond_to do |format|
			format.html { render :index }
			format.js
		end
	end
	
	def price
		session[:return_to] ||= request.referer
		infile = params[:offering][:file].read
		CSV.parse(infile, headers: true, quote_char: '"', col_sep: "\t") do |row|
			offering=Offering.find_or_initialize_by(name: row[0])
  		offering.update_attributes(price: row[1])
		end
		flash[:success] = "Prices Loaded"
		redirect_to new_order_path
		redirect_to session.delete(:return_to)
	end
	

	def replace
		@offering = Offering.find(params[:id])
		offering_id=@offering.id
		replace=Offering.find_or_create_by(name: params[:offering][:name])
		replace.save!
		Order.where(offering_id: offering_id).update_all({:offering_id => replace.id})
		if Order.where(offering_id: offering_id).blank?
			@offering.destroy
		end
		@title = "Current Offerings and their products"
		@offerings=Offering.includes(:products).where("products.id IS NULL").references(:products).paginate(:page => params[:page], :per_page => 10)
	  @blank = true
	  respond_to do |format|
			format.html { render :index }
		end
	end
	
	def autocomplete
		@offerings = Offering.search(params[:term],true)
		render json: @offerings.map(&:name)
	end
	
	def autocomplete_no_price
		@offerings = Offering.search(params[:term],false)
		render json: @offerings.map(&:name)
	end
	
	def price
		@offerings = Offering.search(params[:term],true)
		render json: @offerings.map(&:price)
	end
	
	def show
		@offering = Offering.find(params[:id])
		package=Package.new(@offering.total_weight, [5,5], :units => :imperial)
		origin = Location.new(:country => 'US',:zip => '27217')
		destination_US = Location.new(:country => 'US',:zip => '90210')
		destination_CA = Location.new( :country => 'CA')
		destination_CN = Location.new( :country => 'CN')
		destination_EU = Location.new( :country => 'GB')
		ups = UPS.new(:login => 'rubberbanditz', :password => 'Bandtastic2013', :key => 'DCBBB7D0DD606DD6')
		usps = USPS.new(:login => '970RUBBE0314')
		@response_ups_CA = ups.find_rates(origin, destination_CA, package)
		@response_usps_CA = usps.find_rates(origin, destination_CA, package)
		@response_ups_CN = ups.find_rates(origin, destination_CN, package)
		@response_usps_CN = usps.find_rates(origin, destination_CN, package)
		@response_ups_EU = ups.find_rates(origin, destination_EU, package)
		@response_usps_EU = usps.find_rates(origin, destination_EU, package)
		@response_ups_US = ups.find_rates(origin, destination_US, package)
		@response_usps_US = usps.find_rates(origin, destination_US, package)
	end
	
  def index
    @title = "Current Offerings and their products"
    @search=params[:search]
    
  	@offerings = Offering.search(@search,false)
  	@blank=params[:blank]
  	if @blank.blank?
  	else
	  	@offerings=Offering.includes(:products).where("products.id IS NULL").references(:products)
  	end
  	if params[:sort_by] == "US_ASC"
  		@offerings=@offerings.sort_by {|o| o.amzus.count }
  	elsif params[:sort_by] == "US_DESC"
  	  @offerings=@offerings.sort_by {|o| o.amzus.count }.reverse
  	elsif params[:sort_by] == "NAME_ASC"
  	  @offerings=@offerings.sort_by {|o| o.name }.reverse
  	elsif params[:sort_by] == "NAME_DESC"
  	  @offerings=@offerings.sort_by {|o| o.name }
  	elsif params[:sort_by] == "CA_ASC"
  	  @offerings=@offerings.sort_by {|o| o.amzca.count }
  	elsif params[:sort_by] == "CA_DESC"
  	  @offerings=@offerings.sort_by {|o| o.amzca.count }.reverse
  	elsif params[:sort_by] == "WS_ASC"
  		@offerings=@offerings.sort_by {|o| o.website.count }
  	elsif params[:sort_by] == "WS_DESC"
  		@offerings=@offerings.sort_by {|o| o.website.count }.reverse
  	elsif params[:sort_by] == "BC_ASC"
  		@offerings=@offerings.sort_by {|o| o.buy.count }
  	elsif params[:sort_by] == "BC_DESC"
  		@offerings=@offerings.sort_by {|o| o.buy.count }.reverse
  	elsif params[:sort_by] == "PE_ASC"
  		@offerings=@offerings.sort_by {|o| o.phone.count }
  	elsif params[:sort_by] == "PE_DESC"
  		@offerings=@offerings.sort_by {|o| o.phone.count }.reverse
  	elsif params[:sort_by] == "EB_ASC"
  		@offerings=@offerings.sort_by {|o| o.ebay.count }
  	elsif params[:sort_by] == "EB_DESC"
  		@offerings=@offerings.sort_by {|o| o.ebay.count }.reverse
  	elsif params[:sort_by] == "ALL_ASC"
  		@offerings=@offerings.sort_by {|o| o.count }
  	elsif params[:sort_by] == "ALL_DESC"
  		@offerings=@offerings.sort_by {|o| o.count }.reverse
  	end
  	@offerings=@offerings.paginate(:page => params[:page], :per_page => 10)
  	
  end
  
private


    def offering_params
      params.require(:offering).permit(:name,:price, offering_products_attributes: [:id, :offering_id, :product_id, :product_name, :quantity])
    end
    
end
