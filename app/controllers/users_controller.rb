# encoding: UTF-8
class UsersController < InheritedResources::Base
  actions :create, :edit, :show, :update
  before_filter :authenticate_user!, except: :new

  def new
    redirect_to login_path
  end

  def show
  	params[:id] ||= current_user.id
  	super
  end
end