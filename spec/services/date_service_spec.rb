# frozen_string_literal: true

RSpec.describe DateService, type: :service do
  describe '#skip_weekends' do
    let(:date) { Date.new(2017, 5, 6) }

    context 'when the end date is not a weekend' do
      it { expect(described_class.instance.skip_weekends(date, 3)).to eq Date.new(2017, 5, 9) }
    end

    context 'when the end date is a weekend' do
      it { expect(described_class.instance.skip_weekends(date, 1)).to eq Date.new(2017, 5, 8) }
    end
  end
end
