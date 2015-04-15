require 'spec_helper'
require File.join(Rails.root, '/lib/pag_seguro_adapter.rb')

describe PagSeguroAdapter do
  before(:each) do
    event = FactoryGirl.create(:event)
    @attendance = FactoryGirl.create(:attendance, event: event, registration_date: event.registration_periods.first.start_at)
    @attendance.stubs(:registration_fee).returns(399)
  end

  describe '.from_invoice' do
    let(:invoice) { Invoice.from_attendance(@attendance) }

    it 'will add item for base registration price' do
      adapter = PagSeguroAdapter.from_invoice(invoice)

      expect(adapter.items.size).to eq 1
      expect(adapter.items[0].number).to eq invoice.id
      expect(adapter.items[0].name).to eq invoice.name
      expect(adapter.items[0].quantity).to eq 1
      expect(adapter.items[0].amount).to eq invoice.amount
    end

    it 'should add invoice user' do
      adapter = PagSeguroAdapter.from_invoice(invoice)
      expect(adapter.invoice.user).to eq @attendance.user
    end
  end

  describe '#to_variables' do
    let(:invoice) { Invoice.from_attendance(@attendance) }
    let(:item) { PagSeguroAdapter::PagSeguroItem.new('item 1', 2, 10.50) }

    context 'specifying item variables' do
      it 'map each item variable' do
        adapter = PagSeguroAdapter.new([item], invoice)
        expected_hash = { 'id' => 2, 'description' => 'item 1', 'weight' => 0, 'amount' => 10.50 }

        expect(adapter.to_variables).to eq expected_hash
      end
    end
  end

  describe PagSeguroAdapter::PagSeguroItem do
    it { expect(PagSeguroAdapter::PagSeguroItem.new('item', 2, 10.50).name).to eq 'item' }
    it { expect(PagSeguroAdapter::PagSeguroItem.new('item', 2, 10.50).number).to eq 2 }
    it { expect(PagSeguroAdapter::PagSeguroItem.new('item', 2, 10.50).amount).to eq 10.50 }

    it 'have optional quantity' do
      expect(PagSeguroAdapter::PagSeguroItem.new('item', 2, 10.50).quantity).to eq 1
      expect(PagSeguroAdapter::PagSeguroItem.new('item', 2, 10.50, 3).quantity).to eq 3
    end

    describe '#to_variables' do
      it 'maps item name, number, amount, and quantity for given index' do
        item = PagSeguroAdapter::PagSeguroItem.new('item', 2, 10.50)
        expected_hash = { 'id' => 2, 'description' => 'item', 'weight' => 0, 'amount' => 10.50 }
        expect(item.to_variables(1)).to eq expected_hash
      end
    end
  end
end
