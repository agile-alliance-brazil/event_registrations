require File.join(Rails.root, 'lib', 'pag_seguro_adapter')

module PagSeguroHelper
  def pag_seguro_variables(invoice, return_url, notify_url)
    build_config_vars(invoice, notify_url, return_url)
  end

  private

  def build_config_vars(invoice, notify_url, return_url)
    add_pag_seguro_config_vars(
      PagSeguroAdapter.from_invoice(invoice).to_variables,
        return_url, notify_url
    )
  end

  def add_pag_seguro_config_vars(values, _return_url, notify_url)
    values.tap do |vars|
      vars[:email] = APP_CONFIG[:pag_seguro][:email]
      vars[:token] = APP_CONFIG[:pag_seguro][:token]
      vars[:url_aviso] = notify_url
      vars[:currency] = 'BRL'
    end
  end
end
