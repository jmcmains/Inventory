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
	
	def edit
		@title = "Edit Product"
		@product = Product.find(params[:id])
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
    @products = Product.all
	end
	
	def destroy
    Product.find(params[:id]).destroy
    redirect_to products_path 
  end
end
