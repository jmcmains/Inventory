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
  	i=0;
  	@products=Array.new;
		Product.all.each do |p|
    	@products[i] = @event.product_counts.build(attributes: { product_id: p.id })
    	i=i+1;
  	end
  	render :new
  end
  
  def new_po
  	@event=Event.new(expected_date: Date.today+120)
  	@event.event_type="Product Order"
  	@title="New Product Order"
  	@subtitle=""
   	question = @event.product_counts.build
  end
  
  def receive_po_today
  	@event=Event.find(params[:id])
  	if @event.update_attributes(received_date: Date.today, received: true)
  		flash[:success] = "Purchase Order Received"
  	else
  		flash[:error] = "Purchase Order Was Not Received"
  	end
  	redirect_to po_events_path
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
  	@events=Event.unreceived.sort_by { |i| i.date }.reverse
  	@title= @events.first.event_type
  	@suppliers=Event.unreceived.select("DISTINCT(supplier)")
  	if params[:supplier]
  		@events=Event.unreceived.find_all_by_supplier(params[:supplier]);
  	end
  	@events=@events.paginate(:page => params[:page], :per_page => 10)
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
			render :edit_po
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
