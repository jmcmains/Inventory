class EventsController < ApplicationController
	def new
		@event=Event.new
		Product.all.count.times do
    	question = @event.product_counts.build
  	end
  end
  
  def create
  	@event = Event.new(params[:event])
    @event.save
    redirect_to root_path
  end
  
  def edit
  	@event=Event.find(params[:id])
  	@title = "Edit Event"
  end
  
  def update
  	@event = Event.find(params[:id])
    @event.update_attributes(params[:event])
    redirect_to root_path
  end
end
