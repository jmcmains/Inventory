class SkusController < ApplicationController
  
  def show
  	@sku = Sku.find(params[:id])
  	@origin = params[:origin]
  	@title = @sku.name
  end
  
  def edit
  	@title = "Edit Sku"
  	@sku = Sku.find(params[:id])
  	session[:last_page] = request.env['HTTP_REFERER'] || sku_url(@sku)
  end
  
  def update
  	@sku = Sku.find(params[:id])
  	if @sku.update_attributes(sku_params)
  		redirect_to session[:last_page]
  	else
  		render 'edit'
  	end
  end
  
  def destroy
    Sku.find(params[:id]).destroy
    flash[:success] = "Sku deleted."
    redirect_to :back
  end
private


def sku_params
params.require(:sku).permit(:name,:weight,:height,:length,:width)
end

end
