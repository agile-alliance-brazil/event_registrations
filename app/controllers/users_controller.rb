# encoding: UTF-8
class UsersController < InheritedResources::Base
  layout "eventless"
  actions :show, :edit, :update

  def show
  	params[:id] ||= current_user.id
  	super
  end
end