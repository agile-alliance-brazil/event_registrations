# frozen_string_literal: true

RSpec.describe AttendanceHelper, type: :helper do
  describe '#attendance_price' do
    it 'returns attendance price' do
      attendance = Fabricate.build(:attendance, registration_value: 250)
      expect(attendance_price(attendance)).to eq 250
    end
  end

  describe '#payment_types_options' do
    it { expect(payment_types_options).to eq(options_for_select(Attendance.payment_types.map { |payment_type, _key| [I18n.t("activerecord.attributes.attendance.enums.payment_types.#{payment_type}"), payment_type] }, :gateway)) }
  end

  describe '#job_role_options' do
    it { expect(job_role_options).to eq(options_for_select(Attendance.job_roles.map { |job_role, _key| [I18n.t("activerecord.attributes.attendance.enums.job_role.#{job_role}"), job_role] }.sort_by { |roles| roles[0] }, :not_informed)) }
  end

  describe '#source_of_interest_options' do
    it { expect(source_of_interest_options).to eq(options_for_select(Attendance.source_of_interests.map { |interest, _key| [I18n.t("activerecord.attributes.attendance.enums.source_of_interest.#{interest}"), interest] }, :no_source_informed)) }
  end

  describe '#organization_size_options' do
    it { expect(organization_size_options).to eq(options_for_select(Attendance.organization_sizes.map { |gender_options, _key| [I18n.t("activerecord.attributes.attendance.enums.organization_size.#{gender_options}"), gender_options] }, :no_org_size_informed)) }
  end

  describe '#experience_in_agility_options' do
    it { expect(experience_in_agility_options).to eq(options_for_select(Attendance.experience_in_agilities.map { |exp, _key| [I18n.t("activerecord.attributes.attendance.enums.experience_in_agility.#{exp}"), exp] }, :no_agile_expirience_informed)) }
  end

  describe '#year_of_experience_options' do
    it { expect(year_of_experience_options).to eq(options_for_select(Attendance.years_of_experiences.map { |exp, _key| [I18n.t("activerecord.attributes.attendance.enums.years_of_experience.#{exp}"), exp] }, :no_experience_informed)) }
  end
end
