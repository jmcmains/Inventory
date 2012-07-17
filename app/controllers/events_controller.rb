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
  	@event=Event.new(expected_date: Date.today+120)
  	@event.event_type="Product Order"
  	@title="New Product Order"
  	@subtitle=""
		Product.all.count.times do
    	question = @event.product_counts.build
  	end
  	render :new
  end
  
  def inventory
  	@events=Event.inventory.sort_by { |i| i.date }.reverse.paginate(:page => params[:page], :per_page => 1)
  	@title= @events.first.event_type
  	render :index
  end
  
  def destroy
  	if Event.find(params[:id]).event_type == "Inventory"
  		Event.find(params[:id]).destroy
  	  redirect_to inventory_events_path
  	else
  		Event.find(params[:id]).destroy
  	  redirect_to po_events_path
  	end
  end
  
  def po
  	@events=Event.unreceived
  	@title= @events.first.event_type
  	render :index
  end
  
  def create
  	@event = Event.new(params[:event])
    @event.save
		if @event.event_type == "Inventory"
  	  redirect_to inventory_events_path
  	else
  	  redirect_to po_events_path
  	end
  end
  
  def edit
  	@event=Event.find(params[:id])
  	@title = "Edit Event"
  end
  
  def update
  	@event = Event.find(params[:id])
    @event.update_attributes(params[:event])
    if @event.event_type == "Inventory"
  	  redirect_to inventory_events_path
  	else
  	  redirect_to po_events_path
  	end
  end
end
