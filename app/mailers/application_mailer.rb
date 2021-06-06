# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'inscricoes@agilebrazil.com'
  layout 'mailer'
end
