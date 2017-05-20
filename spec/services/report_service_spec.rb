RSpec.describe ReportService, type: :service do
  describe '#create_burnup_structure' do
    context 'having attendances' do
      let(:event) { FactoryGirl.create :event, start_date: 1.week.from_now, attendance_limit: 4 }
      let!(:first_attendante) { FactoryGirl.create :attendance, event: event }
      let!(:second_attendante) { FactoryGirl.create :attendance, event: event }

      let(:burnup_ideal) { [[1_495_249_200_000, 0.0], [1_495_335_600_000, 0.5714285714285714], [1_495_422_000_000, 1.1428571428571428], [1_495_508_400_000, 1.7142857142857142], [1_495_594_800_000, 2.2857142857142856], [1_495_681_200_000, 2.8571428571428568], [1_495_767_600_000, 3.4285714285714284], [1_495_854_000_000, 4.0]] }
      let(:burnup_actual) { [[1_495_249_200_000, 2]] }

      it 'returns the sctructure for the burnup' do
        burnup_structure = ReportService.instance.create_burnup_structure(event)
        expect(burnup_structure.ideal).to eq burnup_ideal
        expect(burnup_structure.actual).to eq burnup_actual
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
