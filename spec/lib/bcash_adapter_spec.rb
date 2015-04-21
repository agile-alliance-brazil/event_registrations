# encoding: UTF-8
require 'spec_helper'
require File.join(Rails.root, '/lib/bcash_adapter.rb')

describe BcashAdapter do
  before(:each) do
    event = FactoryGirl.create(:event)
    @attendance = FactoryGirl.create(:attendance, event: event, registration_date: event.registration_periods.first.start_at)
    @attendance.stubs(:registration_fee).returns(399)
  end

  describe '.from_invoice' do
    let(:invoice) { Invoice.from_attendance(@attendance) }

    it 'will add item for base registration price' do
      adapter = BcashAdapter.from_invoice(invoice)

      expect(adapter.items.size).to eq 1
      expect(adapter.items[0].amount).to eq @attendance.registration_fee
      expect(adapter.items[0].name).to eq @attendance.full_name
      expect(adapter.items[0].quantity).to eq 1
      expect(adapter.items[0].number).to eq invoice.id
    end

    it 'should add invoice user' do
      adapter = BcashAdapter.from_invoice(invoice)
      expect(adapter.invoice.user).to eq @attendance.user
    end
  end

  describe 'to_variables' do
    let(:invoice) { Invoice.from_attendance(@attendance) }
    it 'map each item variable' do

      adapter = BcashAdapter.new([
                                     BcashAdapter::BcashItem.new('item 1', 2, 10.50),
                                     BcashAdapter::BcashItem.new('item 2', 3, 9.99, 2)
                                 ], invoice)

      expect(adapter.to_variables).to include({
                                                  'produto_valor_1' => 10.50,
                                                  'produto_descricao_1' => 'item 1',
                                                  'produto_qtde_1' => 1,
                                                  'produto_codigo_1' => 2,
                                                  'produto_valor_2' => 9.99,
                                                  'produto_descricao_2' => 'item 2',
                                                  'produto_qtde_2' => 2,
                                                  'produto_codigo_2' => 3
                                              })
    end

    context 'aditional information' do
      let(:item) { BcashAdapter::BcashItem.new('item 1', 2, 10.50) }
      let(:other_item) { BcashAdapter::BcashItem.new('item 2', 3, 9.99, 2) }
      let(:adapter) { BcashAdapter.new([item, other_item], invoice) }
      let(:variables) { adapter.to_variables }

      it { expect(variables['id_pedido']).to eq invoice.id }
      it { expect(variables['frete']).to eq 0 }
      it { expect(variables['email']).to eq invoice.email }
      it { expect(variables['nome']).to eq invoice.name }
      it { expect(variables['cpf']).to eq invoice.cpf }
      it { expect(variables['sexo']).to eq invoice.gender }
      it { expect(variables['cep']).to eq invoice.zipcode }
      it { expect(variables['telefone']).to eq invoice.phone }
      it { expect(variables['endereco']).to eq invoice.address }
      it { expect(variables['bairro']).to eq invoice.neighbourhood }
      it { expect(variables['cidade']).to eq invoice.city }
      it { expect(variables['estado']).to eq invoice.state }
    end
  end

  describe BcashAdapter::BcashItem do
    it "should have name" do
      expect(BcashAdapter::BcashItem.new('item', 2, 10.50).name).to eq('item')
    end

    it "should have number" do
      expect(BcashAdapter::BcashItem.new('item', 2, 10.50).number).to eq(2)
    end

    it "should have amount" do
      expect(BcashAdapter::BcashItem.new('item', 2, 10.50).amount).to eq(10.50)
    end

    it "should have optional quantity" do
      expect(BcashAdapter::BcashItem.new('item', 2, 10.50).quantity).to eq(1)
      expect(BcashAdapter::BcashItem.new('item', 2, 10.50, 3).quantity).to eq(3)
    end

    describe "to_variables" do
      it "should map item name, number, amount, and quantity for given index" do
        item = BcashAdapter::BcashItem.new('item', 2, 10.50)
        expect(item.to_variables(1)).to eq({
                                               'produto_valor_1' => 10.50,
                                               'produto_descricao_1' => 'item',
                                               'produto_qtde_1' => 1,
                                               'produto_codigo_1' => 2
                                           })

        expect(item.to_variables(10)).to eq({
                                                'produto_valor_10' => 10.50,
                                                'produto_descricao_10' => 'item',
                                                'produto_qtde_10' => 1,
                                                'produto_codigo_10' => 2
                                            })
      end
    end
  end
end
