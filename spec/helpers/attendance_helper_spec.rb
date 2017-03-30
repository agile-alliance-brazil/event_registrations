# encoding: UTF-8

describe AttendanceHelper, type: :helper do
  describe '#attendance_price' do
    it 'returns attendance price' do
      attendance = FactoryGirl.build(:attendance, registration_value: 250)
      expect(attendance_price(attendance)).to eq 250
    end
  end

  describe '#price_table_link' do
    it 'show pure link if no locale information in the link' do
      event = FactoryGirl.build(:event)
      expect(price_table_link(event, :pt)).to eq(event.price_table_link)
      expect(price_table_link(event, :en)).to eq(event.price_table_link)
    end

    it 'replaces :locale placeholder in the link if present' do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing/:locale/works')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing/pt/works')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing/en/works')
    end

    it 'works as a query param as well' do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing?locale=:locale')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing?locale=pt')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing?locale=en')
    end
  end

  describe '#payment_types_options' do
    it do
      options = Invoice.payment_types.map do |payment_type, _|
        [I18n.t("activerecord.attributes.invoice.payment_types.#{payment_type}"), payment_type]
      end
      expect(payment_types_options).to eq(options)
    end
  end
end
