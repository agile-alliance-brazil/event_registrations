# frozen_string_literal: true

describe AttendanceExportService, type: :service do
  describe '.to_csv' do
    context 'with attendances' do
      let(:event) { FactoryBot.create :event }
      let(:group) { FactoryBot.create :registration_group, event: event, name: 'Group for to csv test' }
      let!(:attendance) do
        FactoryBot.create(:attendance,
                          event: event,
                          status: :showed_in,
                          first_name: 'bLa',
                          registration_group: group)
      end

      let(:expected) do
        title = "id,status,registration_date,first_name,last_name,organization,email,payment_type,group_name,city,state,value,experience_in_agility,education_level,job_role\n"
        body =
          "#{attendance.id},"\
          "#{I18n.t("activerecord.attributes.attendance.enums.status.#{attendance.status}", count: 1)},"\
          "#{attendance.registration_date},"\
          "#{attendance.first_name},"\
          "#{attendance.last_name},"\
          "#{attendance.organization},"\
          "#{attendance.email},"\
          "#{attendance.payment_type},"\
          "#{attendance.group_name},"\
          "#{attendance.city},"\
          "#{attendance.state},"\
          "#{attendance.registration_value},"\
          "#{attendance.experience_in_agility},"\
          "#{attendance.education_level},"\
          "#{attendance.organization_size},"\
          "#{attendance.job_role}\n"
        title + body
      end
      it { expect(AttendanceExportService.to_csv(event.attendances)).to eq expected }
    end
  end
end
