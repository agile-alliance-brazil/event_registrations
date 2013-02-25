# encoding: UTF-8
class AuthenticationsController < ApplicationController
  def destroy
    authentication = current_user.authentications.find(params[:id])
    authentication.destroy

    redirect_to self.current_user
  end
end