# frozen_string_literal: true

RSpec.describe UserHelper, type: :helper do
  describe '#gender_options' do
    it { expect(gender_options).to eq(options_for_select(User.genders.map { |gender_value, _key| [I18n.t("activerecord.attributes.user.enums.gender.#{gender_value}"), gender_value] }, :gender_not_informed)) }
  end

  describe '#disability_options' do
    it { expect(disability_options(nil)).to eq(options_for_select(User.disabilities.map { |disability_values, _key| [I18n.t("activerecord.attributes.user.enums.disability.#{disability_values}"), disability_values] }, nil)) }
    it { expect(disability_options(:disability_not_informed)).to eq(options_for_select(User.disabilities.map { |disability_values, _key| [I18n.t("activerecord.attributes.user.enums.disability.#{disability_values}"), disability_values] }, :disability_not_informed)) }
  end

  describe '#ethnicity_options' do
    it { expect(ethnicity_options).to eq(options_for_select(User.ethnicities.map { |ethnicity_values, _key| [I18n.t("activerecord.attributes.user.enums.ethnicity.#{ethnicity_values}"), ethnicity_values] }, :no_ethnicity_informed)) }
  end

  describe '#education_level_options' do
    it { expect(education_level_options).to eq(options_for_select(User.education_levels.map { |education, _key| [I18n.t("activerecord.attributes.user.enums.education_level.#{education}"), education] }, :no_education_informed)) }
  end
end
