class EventsController < ApplicationController
	def new
		@event=Event.new
		Product.all.count.times do
    	question = @event.product_counts.build
  	end
  end
  
  def load
    date = Date.new(params[:date]["day(1i)"].to_i,params[:date]["day(2i)"].to_i,params[:date]["day(3i)"].to_i)
		ProductCount.import(params[:file],date)
    redirect_to inventory_events_path, notice: "Inventory Loaded."
	end

	def amz_inventory
		@title="Amazon Inventory"
	end
  
  def new_inventory2
  	@event=Event.new
  	@event.event_type="Inventory"
  	@title="Inventory Log"
  	@subtitle=""
  	i=0;
  	@products=Array.new;
		Product.all.sort_by(&:name).each do |p|
    	@products[i] = @event.product_counts.build(attributes: { product_id: p.id })
    	i=i+1;
  	end
  	render :new
  end
  
  def new_inventory
  	event=Event.new(date: Date.today, event_type: "Inventory")
  	inv=Product.get_sv_inventory
  	Product.all.sort_by(&:name).each do |p|
    	event.product_counts.build(attributes: { product_id: p.id, count: inv["#{p.id}"], is_box: false })
  	end
  	event.save!
  	redirect_to inventory_events_path
  end
  
  def new_po
  	@event=Event.new(expected_date: Date.today+120,received_date: Date.today+120)
  	@event.event_type="Product Order"
  	@title="New Product Order"
  	@subtitle=""
  	@show_offer = false
   	question = @event.product_counts.build
  end
  
  def load_fba_shipment
  	infile = params[:event][:file].read
  	origin = params[:event][:event_type]
  	date=Date.new(params[:event]["date(1i)"].to_i,params[:event]["date(2i)"].to_i,params[:event]["date(3i)"].to_i)
  	add_cost=params[:event][:additional_cost]
  	Event.load_fba_shipment(infile,origin,date,add_cost)
		flash[:success] = "Shipment Loaded"
		redirect_to fba_events_path
  end
  
  def new_fba
  	@event=Event.new(expected_date: Date.today+30,received_date: Date.today+30)
  	@title="New Inventory Transfer"
  	@subtitle=""
  	@show_offer = true
   	question = @event.product_counts.build
  end
  
  def edit_fba
  	@event=Event.find(params[:id])
  	@show_offer = true
  	@title = "Edit Event"
  end
  
  def receive_po_today
  	@event=Event.find(params[:id])
  	if @event.update_attributes(received_date: Date.today, received: true)
  		flash[:success] = "Purchase Order Received"
  	else
  		flash[:error] = "Purchase Order Was Not Received"
  	end
  	if @event.event_type="Purchase Order"
  		redirect_to po_events_path
  	else
			redirect_to fba_events_path
  	end
  end
  
  def inventory
  	if params[:date_id]
		  @date = Event.find(params[:date_id])
		else
  	  @date = Event.inventory.sort_by(&:date).last
  	end
  	@events=Event.inventory.where(date: @date.date).paginate(:page => params[:page], :per_page => 1)
  	@title= @events.first.event_type
  	render :index
  end
  
  def destroy
  	session[:last_page] = request.env['HTTP_REFERER'] || po_events_url
  	@event=Event.find(params[:id])
  	event_type=@event.event_type
  	@event.destroy
  	redirect_to session[:last_page]
  end
  
  def fba
  	@title="FBA Shipments"
  	@events=Event.where("event_type LIKE ? OR event_type LIKE ?","Amazon Canada", "Amazon US").sort_by(&:created_at).reverse
  	@events=@events.paginate(:page => params[:page], :per_page => 10)
  end
  
  def po
  	@event_type=params[:event_type]
  	if @event_type == "All Shipments"
  		received=""
  	elsif @event_type == "Received"
			received="received = true AND "
  	elsif @event_type == "In Transit"
  		received="received = false AND"
    elsif @event_type == "Late"
  		received="received = false AND expected_date < ? AND"
  	else
  		received=""
  	end
  	@inv_num= params[:Invoice]? params[:Invoice] : ""
  	@sup_name= params[:Supplier]? params[:Supplier] : ""
  	if @event_type == "Late"
    	if @sup_name.length > 0
    		@supplier = Supplier.where("LOWER(name) LIKE ?","%#{@sup_name.downcase}%").first
			  @events=Event.where("#{received} LOWER(invoice) LIKE ? AND supplier_id = ? AND event_type='Product Order'",Date.today,"%#{@inv_num.downcase}%",@supplier.id)
		  else
			  @events=Event.where("#{received} LOWER(invoice) LIKE ? AND event_type='Product Order'",Date.today,"%#{@inv_num.downcase}%")
		  end
		else
		  if @sup_name.length > 0
    		@supplier = Supplier.where("LOWER(name) LIKE ?","%#{@sup_name.downcase}%").first
			  @events=Event.where("#{received} LOWER(invoice) LIKE ? AND supplier_id = ? AND event_type='Product Order'","%#{@inv_num.downcase}%",@supplier.id)
		  else
			  @events=Event.where("#{received} LOWER(invoice) LIKE ? AND event_type='Product Order'","%#{@inv_num.downcase}%")
		  end
		end
		if @inv_num == ""
			@inv_num=[]
		end
		if @sup_name == ""
			@sup_name=[]
		end
  	if params[:sort_by] == "INV_ASC"
  		@events=@events.sort_by {|a| a.invoice }.reverse
  	elsif params[:sort_by] == "INV_DESC"
  		@events=@events.sort_by {|a| a.invoice }
  	elsif params[:sort_by] == "SUP_ASC"
  		@events=@events.sort_by {|a| a.supplier.blank? ? "" : a.supplier.name }.reverse
  	elsif params[:sort_by] == "SUP_DESC"
  		@events=@events.sort_by {|a| a.supplier.blank? ? "" : a.supplier.name }
  	elsif params[:sort_by] == "DC_ASC"
  		@events=@events.sort_by {|a| a.date }.reverse
  	elsif params[:sort_by] == "DC_DESC"
  		@events=@events.sort_by {|a| a.date }
  	elsif params[:sort_by] == "DE_ASC"
  		@events=@events.sort_by {|a| a.expected_date }.reverse
  	elsif params[:sort_by] == "DE_DESC"
  		@events=@events.sort_by {|a| a.expected_date }
  	elsif params[:sort_by] == "DA_ASC"
  		@events=@events.sort_by {|a| a.received_date }.reverse
  	elsif params[:sort_by] == "DA_DESC"
  		@events=@events.sort_by {|a| a.received_date }
  	end
  	@title= "Product Order"
  	@events=@events.paginate(:page => params[:page], :per_page => 10)
  	render :index
  end
  
  def create
  	@event = Event.new(event_params)
    @event.save
		if @event.event_type == "Inventory"
  	  redirect_to inventory_events_path
  	elsif @event.event_type == "Product Order"
  		@event.product_counts.each do |pc|
  			sp=SupplierPrice.new(date: @event.date, supplier_id: @event.supplier_id, product_id: pc.product_id, quantity: pc.count, price: pc.price/pc.count)
  			sp.save
  		end
  	  redirect_to po_events_path
  	else
  		redirect_to fba_events_path
  	end
  end
  
  def edit
  	@event=Event.find(params[:id])
  	@show_offer = false
  	@title = "Edit Event"
		render :edit_po
  end
  
  def update
  	@event = Event.find(params[:id])
    @event.update_attributes(event_params)
    if @event.event_type == "Inventory"
  	  redirect_to inventory_events_path
  	elsif @event.event_type =="Product Order"
  	  redirect_to po_events_path
  	else
  		redirect_to fba_events_path
  	end
  end
  
  
private


    def event_params
      params.require(:event).permit( :id, :date, :event_type, :invoice, :received_date, :received, :expected_date, :additional_cost, :supplier_id, :product_name, :supplier_name,       product_counts_attributes: [:id, :event_id, :product_id, :count, :is_box, :price, :product_name, '_destroy', :box_count, :piece_count, :sku_name, :offering_id], supplier_attributes: [:id, :supplier_name, :name, '_destroy'] )
    end
end
