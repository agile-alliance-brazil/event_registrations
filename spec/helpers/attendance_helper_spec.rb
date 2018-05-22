# frozen_string_literal: true

describe AttendanceHelper, type: :helper do
  describe '#attendance_price' do
    it 'returns attendance price' do
      attendance = FactoryBot.build(:attendance, registration_value: 250)
      expect(attendance_price(attendance)).to eq 250
    end
  end

  describe '#price_table_link' do
    it 'show pure link if no locale information in the link' do
      event = FactoryBot.build(:event)
      expect(price_table_link(event, :pt)).to eq(event.price_table_link)
      expect(price_table_link(event, :en)).to eq(event.price_table_link)
    end

    it 'replaces :locale placeholder in the link if present' do
      event = FactoryBot.build(:event, price_table_link: 'http://localhost:9292/testing/:locale/works')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing/pt/works')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing/en/works')
    end

    it 'works as a query param as well' do
      event = FactoryBot.build(:event, price_table_link: 'http://localhost:9292/testing?locale=:locale')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing?locale=pt')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing?locale=en')
    end
  end

  describe '#payment_types_options' do
    it 'returns the payment type values' do
      options = Attendance.payment_types.map do |payment_type, _|
        [I18n.t("activerecord.attributes.attendance.payment_types.#{payment_type}"), payment_type]
      end
      expect(payment_types_options).to eq(options)
    end
  end

  describe '#job_role_options' do
    it { expect(job_role_options).to eq Attendance.job_roles.map { |job_role| [t("attendances.new.form.job_role.#{job_role[0]}"), job_role[0]] }.sort_by { |roles| roles[0] } }
  end
end
