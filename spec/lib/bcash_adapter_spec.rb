# encoding: UTF-8
require 'spec_helper'
require File.join(Rails.root, '/lib/bcash_adapter.rb')

describe BcashAdapter do
  before(:each) do
    event = FactoryGirl.create(:event)
    @attendance = FactoryGirl.create(:attendance, event: event, registration_date: event.registration_periods.first.start_at)
    @attendance.stubs(:registration_fee).returns(399)
  end

  describe "from_attendance" do
    it "should add item for base registration price" do
      I18n.with_locale(:en) do
        adapter = BcashAdapter.from_attendance(@attendance)

        expect(adapter.items.size).to eq(1)
        expect(adapter.items[0].amount).to eq(@attendance.registration_fee)
        expect(adapter.items[0].name).to eq("Type of Registration: Individual")
        expect(adapter.items[0].quantity).to eq(1)
        expect(adapter.items[0].number).to eq(@attendance.registration_type.id)
      end
    end

    it "should add invoice" do
      adapter = BcashAdapter.from_attendance(@attendance)
      expect(adapter.invoice).to eq(@attendance)
    end
  end

  describe "to_variables" do
    it "should map each item's variables" do
      adapter = BcashAdapter.new([
        BcashAdapter::BcashItem.new('item 1', 2, 10.50),
        BcashAdapter::BcashItem.new('item 2', 3, 9.99, 2)
      ], @attendance)

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

    it "should add invoice id and frete and client information" do
      adapter = BcashAdapter.new([
        BcashAdapter::BcashItem.new('item 1', 2, 10.50),
        BcashAdapter::BcashItem.new('item 2', 3, 9.99, 2)
      ], @attendance)

      expect(adapter.to_variables).to include({
        'id_pedido' => @attendance.id,
        'frete' => 0,
        'email'    => @attendance.user.email,
        'nome'     => @attendance.user.full_name,
        'cpf'      => @attendance.user.cpf,
        'sexo'     => @attendance.user.gender,
        'cep'      => @attendance.user.zipcode,
        'telefone' => @attendance.user.phone,
        'endereco' => @attendance.user.address,
        'bairro'   => @attendance.user.neighbourhood,
        'cidade'   => @attendance.user.city,
        'estado'   => @attendance.user.state
      })
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
