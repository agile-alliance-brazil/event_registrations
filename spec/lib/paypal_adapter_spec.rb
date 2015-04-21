# encoding: UTF-8
require 'spec_helper'
require File.join(Rails.root, '/lib/paypal_adapter.rb')

describe PaypalAdapter do

  describe '.from_invoice' do

    before(:each) do
      event = FactoryGirl.create(:event)
      @attendance = FactoryGirl.create(:attendance, event: event, registration_date: event.registration_periods.first.start_at)
      @attendance.stubs(:registration_fee).returns(399)
    end
    
    it 'should add item for base registration price' do
      invoice = Invoice.from_attendance(@attendance)

      I18n.with_locale(:en) do
        adapter = PaypalAdapter.from_invoice(invoice)

        expect(adapter.items.size).to eq 1
        expect(adapter.items[0].amount).to eq @attendance.registration_fee
        expect(adapter.items[0].name).to eq @attendance.full_name
        expect(adapter.items[0].quantity).to eq 1
        expect(adapter.items[0].number).to eq invoice.id
      end
    end
    
    it 'should add invoice id' do
      invoice = Invoice.from_attendance(@attendance)
      adapter = PaypalAdapter.from_invoice(invoice)
      expect(adapter.invoice).to eq invoice
    end
  end

  describe "to_variables" do
    it "should map each item's variables" do
      attendance = FactoryGirl.create(:attendance)
      adapter = PaypalAdapter.new([
        PaypalAdapter::PaypalItem.new('item 1', 2, 10.50),
        PaypalAdapter::PaypalItem.new('item 2', 3, 9.99, 2)
      ], attendance)
      
      expect(adapter.to_variables).to include({
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

      expect(adapter.to_variables).to include({
        'invoice' => attendance.id
      })
    end
  end
  
  describe PaypalAdapter::PaypalItem do
    it "should have name" do
      expect(PaypalAdapter::PaypalItem.new('item', 2, 10.50).name).to eq('item')
    end

    it "should have number" do
      expect(PaypalAdapter::PaypalItem.new('item', 2, 10.50).number).to eq(2)
    end
    
    it "should have amount" do
      expect(PaypalAdapter::PaypalItem.new('item', 2, 10.50).amount).to eq(10.50)
    end
    
    it "should have optional quantity" do
      expect(PaypalAdapter::PaypalItem.new('item', 2, 10.50).quantity).to eq(1)
      expect(PaypalAdapter::PaypalItem.new('item', 2, 10.50, 3).quantity).to eq(3)
    end
    
    describe "to_variables" do
      it "should map item name, number, amount, and quantity for given index" do
        item = PaypalAdapter::PaypalItem.new('item', 2, 10.50)
        expect(item.to_variables(1)).to eq({
          'amount_1' => 10.50,
          'item_name_1' => 'item',
          'quantity_1' => 1,
          'item_number_1' => 2
        })

        expect(item.to_variables(10)).to eq({
          'amount_10' => 10.50,
          'item_name_10' => 'item',
          'quantity_10' => 1,
          'item_number_10' => 2
        })
      end
    end
  end
end
