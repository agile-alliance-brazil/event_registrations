# encoding: UTF-8
require File.join(Rails.root, 'lib', 'bcash_adapter')

module BcashHelper
  def build_bcash_variables(attendance, return_url, notify_url)
    add_bcash_config_vars(
      BcashAdapter.from_attendance(attendance).to_variables,
      return_url, notify_url
    )
  end

  def add_bcash_config_vars(values, return_url, notify_url)
    values.tap do |vars|
      vars[:email_loja] = APP_CONFIG[:bcash][:email]
      vars[:tipo_integracao] = "PAD"
      vars[:url_retorno] = return_url
      vars[:url_aviso] = notify_url
      vars[:redirect] = "true"
      vars[:redirect_time] = 5
    end
  end
end
