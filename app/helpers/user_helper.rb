module UserHelper

  def gender_options(selected_value = :gender_not_informed)
    options_for_select(User.genders.map { |gender_value, _key| [I18n.t("activerecord.attributes.user.enums.gender.#{gender_value}"), gender_value] }, selected_value)
  end

  def disability_options(selected_value)
    options_for_select(User.disabilities.map { |disability_values, _key| [I18n.t("activerecord.attributes.user.enums.disability.#{disability_values}"), disability_values] }, selected_value)
  end

  def ethnicity_options(selected_value = :no_ethnicity_informed)
    options_for_select(User.ethnicities.map { |ethnicity_values, _key| [I18n.t("activerecord.attributes.user.enums.ethnicity.#{ethnicity_values}"), ethnicity_values] }, selected_value)
  end

  def education_level_options(selected_value = :no_education_informed)
    options_for_select(User.education_levels.map { |education, _key| [I18n.t("activerecord.attributes.user.enums.education_level.#{education}"), education] }, selected_value)
  end
end