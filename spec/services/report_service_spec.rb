RSpec.describe ReportService, type: :service do
  describe '#create_burnup_structure' do
    context 'having attendances' do
      let(:event) { FactoryBot.create :event, start_date: 1.week.from_now, attendance_limit: 100 }
      let!(:first_attendante) { FactoryBot.create :attendance, event: event, status: :confirmed }
      let!(:second_attendante) { FactoryBot.create :attendance, event: event, status: :confirmed }
      let!(:pending_attendante) { FactoryBot.create :attendance, event: event, status: :pending }
      let!(:accepted_attendante) { FactoryBot.create :attendance, event: event, status: :accepted }
      let!(:paid_attendante) { FactoryBot.create :attendance, event: event, status: :paid }
      let!(:waiting_attendante) { FactoryBot.create :attendance, event: event, status: :waiting }
      let!(:cancelled_attendante) { FactoryBot.create :attendance, event: event, status: :cancelled }
      let!(:accredited_attendante) { FactoryBot.create :attendance, event: event, status: :showed_in }
      let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 40, amount: 100 }
      let!(:other_group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 15, amount: 100 }

      it 'returns the sctructure for the burnup' do
        burnup_structure = ReportService.instance.create_burnup_structure(event)
        expect(burnup_structure.ideal.first).to eq [Time.zone.today.to_time.to_i * 1000, 0.0]
        expect(burnup_structure.ideal.second).to eq [Time.zone.tomorrow.to_time.to_i * 1000, 14.285714285714286]
        expect(burnup_structure.actual).to eq [[Time.zone.today.to_time.to_i * 1000, 58]]
      end
    end

    context 'having no attendances' do
      let(:event) { FactoryBot.create :event, start_date: 1.week.from_now, attendance_limit: 4 }

      it 'returns the sctructure for the burnup' do
        burnup_structure = ReportService.instance.create_burnup_structure(event)
        expect(burnup_structure.ideal).to eq []
        expect(burnup_structure.actual).to eq []
      end
    end
  end
end
