class OfferingsController < ApplicationController
  require 'will_paginate/array'
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
	  @offering.update_attributes(params[:offering])
	  @title = "Current Offerings and their products"
	  @offerings=Offering.all(:include => :products, :conditions => "products.id IS NULL").paginate(:page => params[:page], :per_page => 10)
	  @blank = true
	  respond_to do |format|
			format.html { render :index }
			format.js
		end
	end
	
	def replace
		@offering = Offering.find(params[:id])
		replace=Offering.find_or_create_by_name(params[:offering][:name])
		Order.where(offering_id: @offering.id).update_all({:offering_id => replace.id})
		@offering.destroy
		@title = "Current Offerings and their products"
		@offerings=Offering.all(:include => :products, :conditions => "products.id IS NULL").paginate(:page => params[:page], :per_page => 10)
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
		sql = ActiveRecord::Base.connection()
		@d=sql.execute("SELECT theother.offering_id, offerings.name, count(*) AS how_many_other_times FROM orders as this INNER JOIN orders AS that ON that.offering_id = this.offering_id INNER JOIN orders AS theother ON that.order_number = theother.order_number AND that.offering_id <> theother.offering_id INNER JOIN offerings ON offerings.id = theother.offering_id WHERE this.offering_id = #{params[:id]} GROUP BY theother.offering_id, offerings.name ORDER BY how_many_other_times DESC")
		@offering = Offering.find(params[:id])
	end
	
  def index
    @title = "Current Offerings and their products"
    @search=params[:search]
    
  	@offerings = Offering.search(@search,false)
  	@blank=params[:blank]
  	if @blank.blank?
  	else
  		@offerings=@offerings.all(:include => :products, :conditions => "products.id IS NULL")
  	end
  	if params[:sort_by] == "US_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.amzus.count }
  	elsif params[:sort_by] == "US_DESC"
  	  @offerings=@offerings.sort_by {|o| o.orders.amzus.count }.reverse
  	elsif params[:sort_by] == "NAME_ASC"
  	  @offerings=@offerings.sort_by {|o| o.orders.name }.reverse
  	elsif params[:sort_by] == "NAME_DESC"
  	  @offerings=@offerings.sort_by {|o| o.orders.name }
  	elsif params[:sort_by] == "CA_ASC"
  	  @offerings=@offerings.sort_by {|o| o.orders.amzca.count }
  	elsif params[:sort_by] == "CA_DESC"
  	  @offerings=@offerings.sort_by {|o| o.orders.amzca.count }.reverse
  	elsif params[:sort_by] == "WS_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.website.count }
  	elsif params[:sort_by] == "WS_DESC"
  		@offerings=@offerings.sort_by {|o| o.orders.website.count }.reverse
  	elsif params[:sort_by] == "BC_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.buy.count }
  	elsif params[:sort_by] == "BC_DESC"
  		@offerings=@offerings.sort_by {|o| o.orders.buy.count }.reverse
  	elsif params[:sort_by] == "PE_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.phone.count }
  	elsif params[:sort_by] == "PE_DESC"
  		@offerings=@offerings.sort_by {|o| o.orders.phone.count }.reverse
  	elsif params[:sort_by] == "EB_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.ebay.count }
  	elsif params[:sort_by] == "EB_DESC"
  		@offerings=@offerings.sort_by {|o| o.orders.ebay.count }.reverse
  	elsif params[:sort_by] == "ALL_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.count }
  	elsif params[:sort_by] == "ALL_DESC"
  		@offerings=@offerings.sort_by {|o| o.orders.count }.reverse
  	end
  	@offerings=@offerings.paginate(:page => params[:page], :per_page => 10)
  	
  end
end
