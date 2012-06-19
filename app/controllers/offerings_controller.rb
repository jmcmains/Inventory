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
  end
end
