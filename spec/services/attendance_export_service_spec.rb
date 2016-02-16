describe AttendanceExportService, type: :service do
  describe '.to_csv' do
    context 'with attendances' do
      let(:event) { FactoryGirl.create :event }
      let(:group) { FactoryGirl.create :registration_group, event: event, name: 'Group for to csv test' }
      let!(:attendance) do
        FactoryGirl.create(:attendance,
                           event: event,
                           status: :pending,
                           first_name: 'bLa',
                           registration_group: group)
      end

      let(:expected) do
        title = "first_name,last_name,organization,email,payment_type,group_name,city,state,value\n"
        body =
          "#{attendance.first_name},"\
          "#{attendance.last_name},"\
          "#{attendance.organization},"\
          "#{attendance.email},"\
          "#{attendance.payment_type},"\
          "#{attendance.group_name},"\
          "#{attendance.city},"\
          "#{attendance.state},"\
          "#{attendance.registration_value}\n"
        title + body
      end
      it { expect(AttendanceExportService.to_csv).to eq expected }
    end
  end
end
