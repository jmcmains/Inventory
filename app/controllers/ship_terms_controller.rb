class ShipTermsController < ApplicationController
	def autocomplete
		@ship_terms = Product.search(params[:term])
		render json: @ship_terms.map(&:term)
	end
end
