class SupplierPricesController < ApplicationController
	def destroy
		@supplier_price=SupplierPrice.find(params[:id])
  	@supplier_price.destroy
  	respond_to do |format|
      format.js
    end
	end
	
	def sort
		@product = Product.find(params[:id])
		@supplier_prices=@product.supplier_prices
		if params[:sort_by] == "SUP_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.supplier.name }.reverse
  	elsif params[:sort_by] == "SUP_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.supplier.name }
  	elsif params[:sort_by] == "DATE_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.date }.reverse
  	elsif params[:sort_by] == "DATE_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.date }
  	elsif params[:sort_by] == "TERM_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.ship_term.term }.reverse
  	elsif params[:sort_by] == "TERM_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.ship_term.term }
  	elsif params[:sort_by] == "MOQ_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.quantity }.reverse
  	elsif params[:sort_by] == "MOQ_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.quantity }
  	elsif params[:sort_by] == "PRICE_ASC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.price }.reverse
  	elsif params[:sort_by] == "PRICE_DESC"
  		@supplier_prices=@supplier_prices.sort_by {|a| a.price }
  	end
  	respond_to do |format|
      format.js
    end
	end
end
