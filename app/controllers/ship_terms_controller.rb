class ShipTermsController < ApplicationController
	def autocomplete
		@ship_terms = ShipTerm.search(params[:term])
		render json: @ship_terms.map(&:term)
	end
end
