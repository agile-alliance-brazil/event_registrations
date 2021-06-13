# frozen_string_literal: true

RSpec.describe UserHelper, type: :helper do
  describe '#gender_options' do
    it { expect(gender_options).to eq(User.genders.map { |gender_options, key| [I18n.t("activerecord.attributes.user.enums.gender.#{gender_options}"), key] }) }
  end

  describe '#education_level_options' do
    it { expect(education_level_options).to eq(User.education_levels.map { |education_levels, key| [I18n.t("activerecord.attributes.user.enums.education_level.#{education_levels}"), key] }) }
  end
end
