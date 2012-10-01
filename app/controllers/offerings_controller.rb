class OfferingsController < ApplicationController
  require 'will_paginate/array'
  def new
  end

  def edit
  	@offering=Offering.find(params[:id])
  	@title = "Edit Offering"
  	@offering.offering_products.build
  end
  
	def update
		@offering = Offering.find(params[:id])
    @offering.update_attributes(params[:offering])
    respond_to do |format|
			format.html { redirect_to blank_offerings_path }
			format.js
		end
	end
	
	def autocomplete
		@offerings = Offering.search(params[:term],true)
		render json: @offerings.map(&:name)
	end
	
	def price
		@offerings = Offering.search(params[:term],true)
		render json: @offerings.map(&:price)
	end
	
	def blank
		@offerings=Offering.all(:include => :products, :conditions => "products.id IS NULL").paginate(:page => params[:page], :per_page => 10)
		render :index
	end
	
	def show
		sql = ActiveRecord::Base.connection()
		@d=sql.execute("SELECT theother.offering_id, offerings.name, count(*) AS how_many_other_times FROM orders as this INNER JOIN orders AS that ON that.offering_id = this.offering_id AND that.order_number <> this.order_number INNER JOIN orders AS theother ON that.order_number = theother.order_number AND that.offering_id <> theother.offering_id INNER JOIN offerings ON offerings.id = theother.offering_id WHERE this.offering_id = #{params[:id]} GROUP BY theother.offering_id, offerings.name ORDER BY how_many_other_times DESC")
		@offering = Offering.find(params[:id])
	end
	
  def index
    @title = "Current Offerings and their products"
  	@offerings = Offering.search(params[:search],false)
  	if params[:sort_by] == "US_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.amzus.count }
  	elsif params[:sort_by] == "US_DESC"
  	  @offerings=@offerings.sort_by {|o| o.orders.amzus.count }.reverse
  	elsif params[:sort_by] == "CA_ASC"
  	  @offerings=@offerings.sort_by {|o| o.orders.amzca.count }
  	elsif params[:sort_by] == "CA_DESC"
  	  @offerings=@offerings.sort_by {|o| o.orders.amzca.count }.reverse
  	elsif params[:sort_by] == "WS_ASC"
  		@offerings=@offerings.sort_by {|o| o.orders.website.count }
  	elsif params[:sort_by] == "WS_DESC"
  		@offerings=@offerings.sort_by {|o| o.orders.website.count }.reverse
  	end
  	@offerings=@offerings.paginate(:page => params[:page], :per_page => 10)
  	
  end
end
