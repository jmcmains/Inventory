class OfferingsController < ApplicationController
  def new
  end

  def edit
  	@offering=Offering.find(params[:id])
  	@title = "Edit Offering"
  	if @offering.offering_products.count == 0
  			@offering_products = Array.new(Product.all.count) { @offering.offering_products.build }
  	end
  end
	def update
		@offering = Offering.find(params[:id])
    @offering.update_attributes(params[:offering])
    redirect_to offerings_path
	end
  def index
    @title = "Current Offerings and their products"
  	@offerings = Offering.search(params[:search])
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
  end
end
