class UsersController < ApplicationController
  def new
  	@user = User.new
  	@title = "New User"
  end
  
  def create
  	@user = User.new(params[:user])
  	@user.save
  	flash[:success] = "User Created!"
  	redirect_to root_path
  end
  def show
  	@user = User.find(params[:id])
  	@title = @user.name
  end
end
