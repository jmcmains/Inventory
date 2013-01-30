class ProductsController < ApplicationController

	def new
		@product = Product.new
		@title = "New Product"
	end
	
	def show
		@product = Product.find(params[:id])
		@title = @product.name
	end
	
	def create
		@product = Product.new(params[:product])
    @product.save
    redirect_to products_path
	end
	
	def create_csv
		csv = CSV.generate(col_sep: "\t") do |csv|
			csv << ["name", "quantity per box", "60 day need", "90 day need", "120 day need"]
			Product.all.sort_by(&:id).each do |product|
				csv << [product.name, product.per_box, product.need(60).round, product.need(90).round, product.need(120).round]
			end
		end
		file ="inventory.csv"
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
	
	def show
    @product = Product.find(params[:id])
    @title = @product.name
  end
	
	def index
		@title = "All Products"
    @products = Product.all.sort_by { |a| a.id }.paginate(:page => params[:page], :per_page => 10)
	end
	
	def destroy
    Product.find(params[:id]).destroy
    redirect_to products_path 
  end
end
