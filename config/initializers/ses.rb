# frozen_string_literal: true

if Figaro.env.ses
  ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                         access_key_id: Figaro.env.ses_access_key_id,
                                         secret_access_key: Figaro.env.ses_secret_access_key,
                                         server: Figaro.env.ses_server,
                                         signature_version: 4
end
