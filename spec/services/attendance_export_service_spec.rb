# frozen_string_literal: true

describe AttendanceExportService, type: :service do
  describe '.to_csv' do
    context 'with attendances' do
      let(:event) { Fabricate :event }
      let(:group) { Fabricate :registration_group, event: event, name: 'Group for to csv test' }
      let!(:attendance) { Fabricate(:attendance, event: event, status: :showed_in, registration_group: group) }

      let(:expected) do
        title = "id,status,registration_date,first_name,last_name,badge_name,organization,email,payment_type,group_name,city,state,value,experience_in_agility,education_level,job_role,disability\n"
        body =
          "#{attendance.id}," \
          "#{I18n.t("activerecord.attributes.attendance.enums.status.#{attendance.status}", count: 1)}," \
          "#{attendance.registration_date}," \
          "#{attendance.first_name}," \
          "#{attendance.last_name}," \
          "#{attendance.badge_name}," \
          "#{attendance.organization}," \
          "#{attendance.email}," \
          "#{attendance.payment_type}," \
          "#{attendance.group_name}," \
          "#{attendance.city}," \
          "#{attendance.state}," \
          "#{attendance.registration_value}," \
          "#{attendance.experience_in_agility}," \
          "#{attendance.education_level}," \
          "#{attendance.organization_size}," \
          "#{attendance.job_role}," \
          "#{I18n.t("activerecord.attributes.user.enums.disability.#{attendance.disability}")}\n"
        title + body
      end

      it { expect(described_class.to_csv(event.attendances)).to eq expected }
    end
  end
end
