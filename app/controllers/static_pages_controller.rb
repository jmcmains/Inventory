class StaticPagesController < ApplicationController
  def home
 		@title ="RubberBanditz Inventory Launching Page"
 		@subtitle= "What would you like to do?"
  end
  
  def paypal
  	redirect_to "https://www.paypal.com/us/vst/id=#{params[:Order_ID]}"
  end
end
