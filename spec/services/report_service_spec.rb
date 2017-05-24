RSpec.describe ReportService, type: :service do
  describe '#create_burnup_structure' do
    context 'having attendances' do
      let(:event) { FactoryGirl.create :event, start_date: 1.week.from_now, attendance_limit: 4 }
      let!(:first_attendante) { FactoryGirl.create :attendance, event: event, status: :confirmed }
      let!(:second_attendante) { FactoryGirl.create :attendance, event: event, status: :confirmed }
      let!(:pending_attendante) { FactoryGirl.create :attendance, event: event, status: :pending }
      let!(:accepted_attendante) { FactoryGirl.create :attendance, event: event, status: :accepted }
      let!(:paid_attendante) { FactoryGirl.create :attendance, event: event, status: :paid }
      let!(:waiting_attendante) { FactoryGirl.create :attendance, event: event, status: :waiting }
      let!(:cancelled_attendante) { FactoryGirl.create :attendance, event: event, status: :cancelled }

      it 'returns the sctructure for the burnup' do
        burnup_structure = ReportService.instance.create_burnup_structure(event)
        expect(burnup_structure.ideal.first).to eq [Time.zone.today.to_time.to_i * 1000, 0.0]
        expect(burnup_structure.ideal.second).to eq [Time.zone.tomorrow.to_time.to_i * 1000, 0.5714285714285714]
        expect(burnup_structure.actual).to eq [[Time.zone.today.to_time.to_i * 1000, 2]]
      end
    end

    context 'having no attendances' do
      let(:event) { FactoryGirl.create :event, start_date: 1.week.from_now, attendance_limit: 4 }

      it 'returns the sctructure for the burnup' do
        burnup_structure = ReportService.instance.create_burnup_structure(event)
        expect(burnup_structure.ideal).to eq []
        expect(burnup_structure.actual).to eq []
      end
    end
  end
end
