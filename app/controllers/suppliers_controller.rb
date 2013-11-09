class SuppliersController < ApplicationController
	require 'csv'

	def csv
		infile = params[:supplier][:file].read
		@supplier = Supplier.find(params[:supplier][:supplier_id])
	  CSV.parse(infile, headers: true) do |row|
	  	(3..(row.length-1)).each do |i|
	  		if !row[2].blank? && !row[1].blank?
					product = Product.find_or_create_by_name(row[2])
					product.save
					ship_term = ShipTerm.find_or_create_by_term(row[1])
					ship_term.save
					date=Date.strptime(row[0], '%m/%d/%Y')
		  		sp=SupplierPrice.new(date: date,supplier_id: @supplier.id,product_id: product.id,ship_term_id: ship_term.id,quantity: row.headers[i],price: row[i])
	  			sp.save
	  		end
	  	end
		end
		redirect_to @supplier
	end
	
	def new
		@title = "New Supplier"
		@supplier=Supplier.new
		@supplier.supplier_prices.build
	end
	
	def create
		@supplier = Supplier.new(supplier_params)
    if @supplier.save
  		flash[:success] = "Supplier Created!"
  		redirect_to @supplier
  	else
  		render 'new'
  	end
	end
	
	def edit
		session[:return_to] ||= request.referer
		@title = "Edit Supplier"
  	@supplier = Supplier.find(params[:id])
		if @supplier.supplier_prices.count == 0
			@supplier.supplier_prices.build
		end
	end
	
	def update
		@supplier = Supplier.find(params[:id])
  	if @supplier.update_attributes(supplier_params)
  		flash[:success]= "Supplier Updated"
  		redirect_to session.delete(:return_to)
  	else
  		render 'edit'
  	end
  	
	end
	
	def show
		@supplier = Supplier.find(params[:id])
		@title=@supplier.name
		@shipterm = params[:shipterm]
		@product_name = params[:product_name]
		@quantity = params[:quantity]
		if !params[:shipterm].blank?
			st = ShipTerm.where("LOWER(term) LIKE ?","%#{params[:shipterm].downcase}%").first.id
			if !params[:product_name].blank?
				pn = Product.where("LOWER(name) LIKE ?","%#{params[:product_name].downcase}%").first.id
				if !params[:quantity].blank?
					@supplier_prices=@supplier.supplier_prices.where("ship_term_id = ? AND product_id = ? AND quantity = ?",st,pn,params[:quantity])
				else
					@supplier_prices=@supplier.supplier_prices.where("ship_term_id = ? AND product_id = ?",st,pn)
				end
			else
				if !params[:quantity].blank?
					@supplier_prices=@supplier.supplier_prices.where("ship_term_id = ?  AND quantity = ?",st,params[:quantity])
				else
					@supplier_prices=@supplier.supplier_prices.where("ship_term_id = ?",st)
				end
			end
		else
			if !params[:product_name].blank?
				pn = Product.where("LOWER(name) LIKE ?","%#{params[:product_name].downcase}%").first.id
				if !params[:quantity].blank?
					@supplier_prices=@supplier.supplier_prices.where("product_id = ? AND quantity = ?",pn,params[:quantity])
				else
					@supplier_prices=@supplier.supplier_prices.where("product_id = ?",pn)
				end
			else
				if !params[:quantity].blank?
					@supplier_prices=@supplier.supplier_prices.where("quantity = ?",params[:quantity])
				else
					@supplier_prices=@supplier.supplier_prices
				end
			end
		end
				
		if params[:sort_by] == "DS_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.date }.reverse
  	elsif params[:sort_by] == "DS_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.date }
  	elsif params[:sort_by] == "ST_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.ship_term_term.blank? ? "ZZZ" :a .ship_term_term }.reverse
  	elsif params[:sort_by] == "ST_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.ship_term_term.blank? ? "ZZZ" :a .ship_term_term }
  	elsif params[:sort_by] == "PN_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.product_name }.reverse
  	elsif params[:sort_by] == "PN_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.product_name }
  	elsif params[:sort_by] == "QTY_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.quantity }.reverse
  	elsif params[:sort_by] == "QTY_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.quantity }
   	end
  	
  	respond_to do |format|
      format.js
      format.html
    end
	end
	
	def index
		@suppliers = Supplier.all
		@title ="Suppliers"
	end
	
	def destroy
		@supplier=Supplier.find(params[:id])
  	@supplier.destroy
  	redirect_to suppliers_path
	end

	def autocomplete
		@suppliers = Supplier.search(params[:term])
		render json: @suppliers.map(&:name)
	end
	
	
private


    def supplier_params
      params.require(:supplier).permit(:name,:contact_name,:email,:payment_terms,:phone_number, :supplier_name,:comments,:shore_a_durometer,:tensile_strength,:ultimate_elongation,supplier_prices_attributes: [:id, :date,:supplier_id,:product_id,:product_name,:ship_term_id,:ship_term_term,:quantity,:price])
    end

end
