class ProductsController < ApplicationController

	def new
		@product = Product.new
		@title = "New Product"
	end

	def inventory_worksheet
		@products = Product.all.sort_by { |a| a.name }
		@title = "Inventory Worksheet"
	end
	
	def inventory_worksheet_print
		@products = Product.all.sort_by { |a| a.name }
		@title = "Print Inventory Worksheet"
		render "products/inventory_worksheet", layout: false
	end
	
	def create
		@product = Product.new(params[:product])
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
			Product.all.sort_by(&:id).each do |product|
				csv << [product.name, product.per_box, product.need(60).round, product.need(90).round, product.need(120).round]
			end
		end
		file ="inventory.txt"
		File.open(file, "w"){ |f| f << csv }
		send_file( file, type: 'text/csv')
	end
	
	def edit
		@title = "Edit Product"
		@product = Product.find(params[:id])
	end

	def autocomplete
		@products = Product.search(params[:term])
		render json: @products.map(&:name)
	end
	
	def update
		@product = Product.find(params[:id])
		@product.update_attributes(params[:product])
		redirect_to @product
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
	
	def show
    @product = Product.find(params[:id])
    @title = @product.name
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
  end
	
	def index
		@title = "All Products"
    @products = Product.all.sort_by { |a| a.name }.paginate(:page => params[:page], :per_page => 10)
	end
	
	def destroy
    Product.find(params[:id]).destroy
    redirect_to products_path 
  end
end
