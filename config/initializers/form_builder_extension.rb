# encoding: UTF-8
module ActionView
  module Helpers
    class FormBuilder
      alias_method :country_select, :localized_country_select
    end
  end
end