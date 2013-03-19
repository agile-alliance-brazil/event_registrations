# encoding: UTF-8
class PaymentNotificationsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action
  protect_from_forgery :except => [:create]
  
  def create
    attributes = params[:type] == 'bcash' ? PaymentNotification.from_bcash_params(params) : PaymentNotification.from_paypal_params(params)
    puts attributes.inspect
    PaymentNotification.create!(attributes)
    render :nothing => true
  end
end
