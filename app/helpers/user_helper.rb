module UserHelper

  def gender_options
    User.genders.map { |gender_options, key| [I18n.t("activerecord.attributes.user.enums.gender.#{gender_options}"), key] }
  end

  def education_level_options
    User.education_levels.map { |education, key| [I18n.t("activerecord.attributes.user.enums.education_level.#{education}"), key] }
  end
end