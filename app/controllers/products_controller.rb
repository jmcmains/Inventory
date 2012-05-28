class ProductsController < ApplicationController

	def new
		@product = Product.find(params[:id])
		@title = @product.name
	end
	
	def show
		@product = Product.find(params[:id])
		@title = "New Product"
	end
	
	def create
		@product = Product.new(params[:product])
    @product.save
    redirect_to products_path
	end
	
	def edit
		@title = "Edit Product"
	end
	
	def update
		@product = Product.find(params[:product])
		@product.update_attributes(params[:product])
		redirect_to products_path
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
