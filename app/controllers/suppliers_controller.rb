class SuppliersController < ApplicationController

	def autocomplete
		@suppliers = Supplier.search(params[:term])
		render json: @suppliers.map(&:name)
	end
end
