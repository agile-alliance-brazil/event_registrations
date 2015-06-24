# encoding: UTF-8
class PaymentNotificationsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action
  protect_from_forgery :except => [:create]

  def create
    attributes = PaymentNotification.send "from_#{params[:type]}_params", params
    PaymentNotification.create!(attributes)
    render :nothing => true
  end
end