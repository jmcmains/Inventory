class EventsController < ApplicationController
	def new
		@event=Event.new
		Product.all.count.times do
    	question = @event.product_counts.build
  	end
  end
  
  def new_inventory
  	@event=Event.new
  	@event.event_type="Inventory"
  	@title="Inventory Log"
  	@subtitle=""
		Product.all.count.times do
    	question = @event.product_counts.build
  	end
  	render :new
  end
  
  def new_po
  	@event=Event.new
  	@event.event_type="Product Order"
  	@title="New Product Order"
  	@subtitle=""
		Product.all.count.times do
    	question = @event.product_counts.build
  	end
  	render :new
  end
  
  def inventory
  	@events=Event.find_all_by_event_type("Inventory")
  	@title= @events.first.event_type
  	render :index
  end
  
  def po
  	@events=Event.find_all_by_event_type("Product Order")
  	@title= @events.first.event_type
  	render :index
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
