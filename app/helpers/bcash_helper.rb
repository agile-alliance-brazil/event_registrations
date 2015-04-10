# encoding: UTF-8
require File.join(Rails.root, 'lib', 'bcash_adapter')

module BcashHelper
  def bcash_variables(invoice, return_url, notify_url)
    build_config_vars(invoice, notify_url, return_url)
  end

  def bcash_variables_from_attendance(attendance, return_url, notify_url)
    invoice = Invoice.from_attendance(attendance)
    build_config_vars(invoice, notify_url, return_url)
  end

  def bcash_variables_from_group(group, return_url, notify_url)
    invoice = Invoice.from_registration_group(group)
    build_config_vars(invoice, notify_url, return_url)
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

  private

  def build_config_vars(invoice, notify_url, return_url)
    add_bcash_config_vars(
        BcashAdapter.from_invoice(invoice).to_variables,
        return_url, notify_url
    )
  end
end
