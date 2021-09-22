# frozen_string_literal: true

describe RegistrationPeriod, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :event }
    it { is_expected.to have_many :attendances }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :event }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :start_at }
    it { is_expected.to validate_presence_of :end_at }
  end

  describe '.for' do
    before { travel_to Time.zone.local(2019, 9, 3, 16, 0, 0) }

    let(:event) { Fabricate :event }
    let!(:first_period) { Fabricate :registration_period, start_at: 2.days.ago, end_at: 1.day.from_now.end_of_day, event: event }
    let!(:second_period) { Fabricate :registration_period, start_at: 2.days.from_now, end_at: 4.days.from_now.end_of_day, event: event }

    context 'appropriate period' do
      it { expect(described_class.for(Time.zone.yesterday).first).to eq first_period }
      it { expect(described_class.for(Time.zone.today).first).to eq first_period }
      it { expect(described_class.for(Time.zone.tomorrow).first).to eq first_period }
      it { expect(described_class.for(2.days.from_now).first).to eq second_period }
      it { expect(described_class.for(3.days.from_now).first).to eq second_period }
      it { expect(described_class.for(4.days.from_now).first).to eq second_period }
    end
  end
end
