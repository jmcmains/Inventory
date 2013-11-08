class ProductCountsController < ApplicationController
	def new
		@event=Event.new
		@product_count = Array.new(Product.all.count) { @event.product_counts.build }
	end
	
	def create
	
	end
	
private


    def product_count_params
      params.require(:product_count).permit(:event_id,:product_id,:count,:is_box,:price)
    end
    
end
