# encoding: UTF-8
require 'spec_helper'

describe PaymentNotificationsController do
  describe "POST create" do
    it "should create PaymentNotification" do
      attendance = FactoryGirl.create(:attendance)
      
      lambda {
        post :create, :txn_id => "ABCABC", :invoice => attendance.id, :custom => 'Attendance', :payment_status => "Completed"
      }.should change(PaymentNotification, :count).by(1)      
    end
  end
end
