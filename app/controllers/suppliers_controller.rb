class SuppliersController < ApplicationController
	def new
		@title = "New Supplier"
		@supplier=Supplier.new
		@supplier.supplier_prices.build
	end
	
	def create
		@supplier = Supplier.new(params[:supplier])
    if @supplier.save
  		flash[:success] = "Supplier Created!"
  		redirect_to @supplier
  	else
  		render 'new'
  	end
	end
	
	def edit
		@title = "Edit Supplier"
  	@supplier = Supplier.find(params[:id])
		if @supplier.supplier_prices.count == 0
			@supplier.supplier_prices.build
		end
	end
	
	def update
		@supplier = Supplier.find(params[:id])
  	if @supplier.update_attributes(params[:supplier])
  		flash[:success]= "Supplier Updated"
  		redirect_to @supplier
  	else
  		render 'edit'
  	end
  	
	end
	
	def show
		@supplier = Supplier.find(params[:id])
		@title=@supplier.name
	end
	
	def index
		@suppliers = Supplier.all
		@title ="Suppliers"
	end
	
	def destroy
		@supplier=Supplier.find(params[:id])
  	@supplier.destroy
	end

	def autocomplete
		@suppliers = Supplier.search(params[:term])
		render json: @suppliers.map(&:name)
	end
end
