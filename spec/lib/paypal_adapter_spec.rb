# encoding: UTF-8
require 'spec_helper'
require File.join(Rails.root, '/lib/paypal_adapter.rb')

describe PaypalAdapter do
  describe "from_attendance" do
    before(:each) do
      @attendance ||= FactoryGirl.create(:attendance, :registration_date => Time.zone.local(2013, 5, 1))
    end
    
    it "should add item for base registration price" do
      I18n.with_locale(:en) do
        adapter = PaypalAdapter.from_attendance(@attendance)

        adapter.items.size.should == 1
        adapter.items[0].amount.should == @attendance.base_price
        adapter.items[0].name.should == "Type of Registration: Individual"
        adapter.items[0].quantity.should == 1
        adapter.items[0].number.should == @attendance.registration_type.id
      end
    end
    
    it "should add invoice id" do
      adapter = PaypalAdapter.from_attendance(@attendance)
      adapter.invoice.should == @attendance
    end
  end

  describe "to_variables" do
    it "should map each item's variables" do
      attendance = FactoryGirl.create(:attendance)
      adapter = PaypalAdapter.new([
        PaypalAdapter::PaypalItem.new('item 1', 2, 10.50),
        PaypalAdapter::PaypalItem.new('item 2', 3, 9.99, 2)
      ], attendance)
      
      adapter.to_variables.should include({
        'amount_1' => 10.50,
        'item_name_1' => 'item 1',
        'quantity_1' => 1,
        'item_number_1' => 2,
        'amount_2' => 9.99,
        'item_name_2' => 'item 2',
        'quantity_2' => 2,
        'item_number_2' => 3
      })
    end
    
    it "should add invoice id" do
      attendance = FactoryGirl.create(:attendance)
      adapter = PaypalAdapter.new([
        PaypalAdapter::PaypalItem.new('item 1', 2, 10.50),
        PaypalAdapter::PaypalItem.new('item 2', 3, 9.99, 2)
      ], attendance)

      adapter.to_variables.should include({
        'invoice' => attendance.id
      })
    end
  end
  
  describe PaypalAdapter::PaypalItem do
    it "should have name" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).name.should == 'item'
    end

    it "should have number" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).number.should == 2
    end
    
    it "should have amount" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).amount.should == 10.50
    end
    
    it "should have optional quantity" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).quantity.should == 1
      PaypalAdapter::PaypalItem.new('item', 2, 10.50, 3).quantity.should == 3
    end
    
    describe "to_variables" do
      it "should map item name, number, amount, and quantity for given index" do
        item = PaypalAdapter::PaypalItem.new('item', 2, 10.50)
        item.to_variables(1).should == {
          'amount_1' => 10.50,
          'item_name_1' => 'item',
          'quantity_1' => 1,
          'item_number_1' => 2
        }

        item.to_variables(10).should == {
          'amount_10' => 10.50,
          'item_name_10' => 'item',
          'quantity_10' => 1,
          'item_number_10' => 2
        }
      end
    end
  end
end
