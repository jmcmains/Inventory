class ProductsController < ApplicationController

	def new
		@product = Product.new
		@title = "New Product"
	end

	def inventory_worksheet
		@products = Product.all.sort_by { |a| a.name }
		if params[:start_date_id]
		@start_date = Event.find(params[:start_date_id])
  	@end_date = Event.find(params[:end_date_id])
		else
 		@start_date = Event.inventory.sort_by(&:date).last(2).first
  	@end_date = Event.inventory.sort_by(&:date).last
  	end
		@title = "Inventory Worksheet"
	end
	
	def inventory_worksheet_print
		@products = Product.all.sort_by { |a| a.name }
		@title = "Print Inventory Worksheet"
		render "products/inventory_worksheet", layout: false
	end
	
	def create
		@product = Product.new(product_params)
    @product.save
    redirect_to products_path
	end
	
	def cogs
		@product = Product.find(params[:id])
    if params[:start_date]
  		@start_date = Date.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
  		@end_date = Date.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
  	else
  		@start_date = Date.today.beginning_of_year
  		@end_date = Date.today.end_of_year
  	end
  	output = @product.cogs(@start_date,@end_date)
  	@value=output["value"]
		@orders=output["purchases"]
		respond_to do |format|
      format.js
    end
	end
	
	def create_csv
		csv = CSV.generate(col_sep: "\t") do |csv|
			csv << ["name", "quantity per box", "60 day need", "90 day need", "120 day need"]
			Product.find_all_by_display(true).sort_by(&:id).each do |product|
				csv << [product.name, product.per_box, product.need(60).round, product.need(90).round, product.need(120).round]
			end
		end
		file ="inventory.txt"
		File.open(file, "w"){ |f| f << csv }
		send_file( file, type: 'text/csv')
	end
	
	def accounting_csv
		start_date = Date.new(1990,1,1)
		end_date = Date.today
		csv = CSV.generate(col_sep: "\t") do |csv|
			csv << ["Name", "Total Sales", "Total Cost of Goods Sold", "Average Inventory", "Average Price"]
			Product.find_all_by_display(true).sort_by(&:name).each do |product|
				output = product.cogs(start_date,end_date)
				csv << [product.name, output["purchases"], output["value"], product.average_inventory(start_date,end_date), product.avg_price]
			end
		end
		file ="accounting.txt"
		File.open(file, "w"){ |f| f << csv }
		send_file( file, type: 'text/csv')
	end
	
	def margin_csv
	  start_date = Date.today - 6.months
		end_date = Date.today
		csv = CSV.generate(col_sep: "\t") do |csv|
			csv << ["Product Name", "Product Cost", "Average Retail Price", "Margin", "Total Sales"]
			Product.where(display: true).sort_by(&:name).each do |product|
				output = product.cogs(start_date,end_date)
        if output["purchases"] > 0
				  csv << [product.name, output["value"]/output["purchases"], product.avg_price, product.avg_price-output["value"]/output["purchases"], output["purchases"]]
				end
			end
		end
		file ="margins.txt"
		File.open(file, "w"){ |f| f << csv }
		send_file( file, type: 'text/csv')
	end
	
	def edit
		@title = "Edit Product"
		@product = Product.find(params[:id])
		if @product.supplier_prices.count == 0
			@product.supplier_prices.build
		end
	end

	def autocomplete
		@products = Product.search(params[:term])
		render json: @products.map(&:name)
	end
	
	def update
		@product = Product.find(params[:id])
  	if @product.update_attributes(product_params)
  		flash[:success]= "Product Updated"
  		redirect_to @product
  	else
  		render 'edit'
  	end
	end
	
	def all_cogs
		@title ="Cost of Goods Sold"
		if params[:start_date]
  		@start_date = Date.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
  		@end_date = Date.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
  	else
  		@start_date = Date.today.beginning_of_year
  		@end_date = Date.today.end_of_year
  	end
  	@product={}
		@value={}
		@orders={}
		@avg={}
		@value_total=0
		@orders_total=0
  	Product.all.sort_by(&:id).each_with_index do |product,i|
  		output=product.cogs(@start_date,@end_date)
  		@product[i]=product
			@value[i]=output["value"]
			@orders[i]=output["purchases"]
			@value_total=@value[i]+@value_total
			@orders_total=@orders[i]+@orders_total
  	end
	end
	def margin
	  @start_date = Date.today - 6.months
    @end_date = Date.today
    @title = "Product Margins"
	  @products=Product.where(display: true).sort_by(&:name).paginate(:page => params[:page], :per_page => 10)
	end
	
	def show
    @product = Product.find(params[:id])
    @supplier_prices=@product.supplier_prices
    @title = @product.name
    if params[:start_date]
  		@start_date = Date.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
  		@end_date = Date.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
  	else
  		@start_date = Date.today.beginning_of_year
  		@end_date = Date.today
  	end
  	output = @product.cogs(@start_date,@end_date)
  	@value=output["value"]
		@orders=output["purchases"]
		@ido=@product.inventory_days_outstanding(@start_date,@end_date)
		@it=@product.inventory_turns(@start_date,@end_date)
		@avg_price=@product.avg_price
		@margin=@product.margin(@start_date,@end_date)
  end
	
	def index
		@title = "All Products"
    @products = Product.where(display: true).sort_by { |a| a.name }.paginate(:page => params[:page], :per_page => 10)
	end
	
	def destroy
    Product.find(params[:id]).destroy
    redirect_to products_path 
  end
  
  
private


    def product_params
      params.require(:product).permit(:name,:description,:per_box,:imloc,:weight,:display, :product_name,:price,:sku, supplier_prices_attributes: [:id,:date,:supplier_id,:product_id,:supplier_name,:product_name,:ship_term_term, :quantity, :price, '_destroy'],supplier_attributes: [:id, :supplier_name, :name, '_destroy'])
    end
    
end
